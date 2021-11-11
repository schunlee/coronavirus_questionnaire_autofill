#!/usr/bin/env python
# coding=utf-8
import re
import time

import oss2
import json
import uuid
import datetime

import requests
from flask import request
from flask import Flask, jsonify
from flask import make_response
from retry import retry

from google_cloud_datastore import record_data, client

try:
    from urllib.parse import urlparse
except:
    from urlparse import urlparse

app = Flask(__name__)

base_path = ''
DEBUG_FLAG = True


@retry(tries=5, delay=30)
def upload2aliyun(data_json, date_str, uuid_str):
    access_key_id = "LTAI4FdxHGPMAk7X3BWZV5oj"
    access_key_secret = "cNAFZKUC3QXMQJNFAK4ZV4dwyNPmIr"
    endpoint = "https://oss-cn-shenzhen.aliyuncs.com"
    bucket_name = "upload-nexa-test"

    bucket = oss2.Bucket(oss2.Auth(access_key_id, access_key_secret), endpoint, bucket_name)
    key = 'appsflyer/{}/{}.json'.format(date_str, uuid_str)

    print(">>> Upload data to aliyun -> {}".format(key))
    return bucket.put_object(key, json.dumps(data_json))


@app.route('/appsflyer', methods=['POST'])
def upload_handler():
    '''
    {
      "idfv": "E7087037-5BB1-4F46-BDE6-B8B6581D6C6B",
      "product_id": "unicorn.slime.premium.weekly.8.99.promo.01",
      "price": "\u00a528.00",
      "currency": "CNY",
      "idfa": "FA4EEEE2-41EB-4B49-B122-0705A7D83DE2",
      "os": "13.4.1",
      "appsflyer_id": "1629191854863-7087037",
      "transaction_id": "1000000906777019"
    }
    :return:
    '''
    if request.method != "POST":
        return make_response(jsonify({"message": "Method Not Allowed", "code": "Failed"}), 405)
    data_str = request.get_data()
    data_json = json.loads(data_str)
    print("data => {}".format(data_str))

    uuid_str = str(uuid.uuid1())
    today_str = str(datetime.datetime.today().date())
    rec_timestamp = int(round(time.time() * 1000))

    try:
        upload2aliyun(data_json, today_str, uuid_str)
    except Exception as err:
        print("Upload raw data to aliyun failed", err)
    print("Upload raw data to aliyun successfully")
    sdk_raw_url = "https://upload-nexa-test.oss-cn-shenzhen.aliyuncs.com/appsflyer/{}/{}.json".format(today_str,
                                                                                                      uuid_str)
    if DEBUG_FLAG:
        msg = "\n\n".join(["【SDK】", str(datetime.datetime.now()), sdk_raw_url, "###########"])
        requests.get("https://snowy-water-32b3.bill-li.workers.dev/?form=text&content={}".format(msg))

    # record data to google cloud datastore
    transaction_id = data_json.get("transaction_id")
    if transaction_id:
        # 如果transaction_id非空，记录进google cloud datastore
        # https://cloud.google.com/datastore/docs/concepts/entities#creating_an_entity
        property_dict = data_json
        property_dict.update({"rec_timestamp": rec_timestamp,
                              "raw_url": sdk_raw_url
                              })
        record_data(client, "AppSdk", uuid_str, property_dict)
    msg = {"message": "Data Received", "code": "SUCCESS"}
    resp_obj = make_response(jsonify(msg), 200)
    return resp_obj


def handler(environ, start_response):
    parsed_tuple = urlparse(environ['fc.request_uri'])
    li = parsed_tuple.path.split('/')
    global base_path
    if not base_path:
        base_path = "/".join(li[0:5])
    return app(environ, start_response)
