#!/usr/bin/env python
# coding=utf-8
import json
import re
import time
import uuid
from ast import literal_eval
import base64
import datetime
import oss2
import requests
from flask import jsonify
from flask import make_response
from retry import retry

from appsflyer import send_server_to_server
from google_cloud_datastore import record_data, client, get_lastest_target_by_key

DEBUG_FLAG = True


def decodeJwsStr(jws_string):
    jws_payload = jws_string.split(".")[1]
    jws_payload += "=" * ((4 - len(jws_payload) % 4) % 4)

    payload = base64.b64decode(jws_payload).decode('utf8')
    payload = payload.replace("true", "True").replace("false", "False")
    payload_json = literal_eval(payload)
    return payload_json


def parseApplePayload(jws_string):
    payload = decodeJwsStr(jws_string)
    item_dict = {}
    for key, value in payload["data"].items():
        if "signed" in key:
            item_dict.update({key.replace("signed", "").title(): decodeJwsStr(value)})
        else:
            item_dict.update({key: value})
    payload["data"] = item_dict
    return payload


def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    if request.method != "POST":
        return make_response(jsonify({"message": "Method Not Allowed", "code": "Failed"}), 405)

    origin_dict = request.get_json()
    data_str = json.dumps(origin_dict)
    print("data => {}".format(data_str))
    if "signedPayload" in origin_dict:
        print("== notification v2 ==")
        data = parseApplePayload(origin_dict["signedPayload"])
    else:
        print("== notification v1 ==")
        data = origin_dict

    uuid_str = str(uuid.uuid1())
    today_str = str(datetime.datetime.today().date())
    apple_raw_url = "https://upload-nexa-test.oss-cn-shenzhen.aliyuncs.com/apple_test_v2/{}/{}.json".format(
        today_str, uuid_str)

    try:
        upload2aliyun(json.dumps(data), today_str, uuid_str)
    except Exception as err:
        print("Upload raw data to aliyun failed", err)
    print("Upload raw data to aliyun successfully")

    if DEBUG_FLAG:
        msg = "\n\n".join(["【Apple】", str(datetime.datetime.now()), apple_raw_url, "###########"])
        requests.get("https://snowy-water-32b3.bill-li.workers.dev/?form=text&content={}".format(msg))

    # record data to google cloud datastore
    # now only do v2 test

    try:
        if "data" in origin_dict and "Transactioninfo" in origin_dict and "Renewalinfo" in origin_dict:
            # 排除data为空的无效收集数据
            transaction_id = origin_dict["data"]["Transactioninfo"].get("originalTransactionId")
            if transaction_id:
                notification_type = origin_dict["notificationType"]
                app_id = origin_dict["data"]["appAppleId"]
                bundle_id = origin_dict["data"]["bundleId"]
                product_id = origin_dict["data"]["Transactioninfo"]["productId"]
                renewal = True if str(origin_dict["data"]["Renewalinfo"]["autoRenewStatus"]) == '1' else False

                property_dict = {"af_content_type": notification_type,
                                 "af_content_id": product_id,
                                 "bundle_id": bundle_id,
                                 "raw_url": apple_raw_url,
                                 "app_id": app_id,
                                 "renewal": renewal}
                # 如果transaction_id非空，记录进google cloud datastore
                # https://cloud.google.com/datastore/docs/concepts/entities#creating_an_entity
                record_data(client, "AppleNotification", transaction_id, property_dict)
                time_start = time.time()
                time_out = time_start + 60 * 5  # 5 minutes from now
                i = 0
                while time.time() < time_out:
                    print("=== {} ===".format(i))
                    send_to_appsflyer(transaction_id, app_id, bundle_id, notification_type, product_id, apple_raw_url,
                                      renewal)
                    i += 1
    except Exception as err:
        # 捕捉异常，避免苹果重新发notification
        print(err)

    msg = {"message": "Data Received", "code": "SUCCESS"}
    resp_obj = make_response(jsonify(msg), 200)
    return resp_obj


def send_to_appsflyer(transaction_id, app_id, bundle_id, notification_type, product_id, apple_raw_url, renewal):
    sdk_data = get_lastest_target_by_key(client, "AppSDK", transaction_id)

    if sdk_data:
        # 如果AppSDK Entity中存在transaction_id对应的数据，则组合起来向appsflyer发送事件请求
        appsflyer_id = sdk_data.appsflyer_id
        idfa = sdk_data.idfa
        idfv = sdk_data.idfv
        os = sdk_data.os
        currency = sdk_data.currency
        revenue = sdk_data.revenue
        if revenue:
            # 去掉货币符号，转为float，扣除30%苹果税
            revenue = float(re.search('(\d+\.*\d*)', revenue).groups()[0]) * 0.7

        callback = send_server_to_server(app_id, appsflyer_id, currency, idfa, idfv, os, bundle_id, revenue,
                                         notification_type, product_id, renewal)
        if DEBUG_FLAG:
            msg = "\n\n".join(
                ["【To Appsflyer】", str(datetime.datetime.now()), transaction_id, apple_raw_url, sdk_data.raw_url,
                 callback, "###########"])
            requests.get("https://snowy-water-32b3.bill-li.workers.dev/?form=text&content={}".format(msg))
    time.sleep(5)


@retry(tries=5, delay=30)
def upload2aliyun(data_str, date_str, uuid_str):
    access_key_id = "LTAI4FdxHGPMAk7X3BWZV5oj"
    access_key_secret = "cNAFZKUC3QXMQJNFAK4ZV4dwyNPmIr"
    endpoint = "https://oss-cn-shenzhen.aliyuncs.com"
    bucket_name = "upload-nexa-test"

    bucket = oss2.Bucket(oss2.Auth(access_key_id, access_key_secret), endpoint, bucket_name)
    key = 'apple_test_v2/{}/{}.json'.format(date_str, uuid_str)
    print(">>> Upload data to aliyun -> {}".format(key))
    bucket.put_object(key, data_str)
