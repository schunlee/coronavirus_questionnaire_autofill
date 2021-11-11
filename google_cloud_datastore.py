#!/usr/bin/env python
# coding=utf-8
import os

from google.cloud import datastore
from google.oauth2 import service_account

# google.auth.credentials.Credentials
credentials = service_account.Credentials.from_service_account_file(
    os.path.join(os.path.dirname(os.path.abspath("__file__")), "1181_key.json"))

client = datastore.Client("nexa-1181", credentials=credentials)


def record_data(client, source, transaction_id, property_dict):
    '''
    source -> AppSdk, AppleNotification
    :param client:
    :param source:
    :param transaction_id:
    :param property_dict:
    :return:
    '''
    key = client.key(source, transaction_id)
    entity = datastore.Entity(key=key)
    entity.update(property_dict)
    client.put(entity)


def get_target_by_key(client, source, transaction_id):
    '''
    source -> AppleNotification
    :param client:
    :param source:
    :param transaction_id:
    :return: None or Entity obj
    '''
    key = client.key(source, transaction_id)
    item = client.get(key)
    return item


def get_lastest_target_by_key(client, source, transaction_id):
    '''
    source -> AppSdk
    :param client:
    :param source:
    :param transaction_id:
    :return: None or Entity obj
    '''
    query = client.query(kind=source)
    items = query.add_filter('transaction_id', '=', transaction_id).fetch()
    items = filter(lambda
                       x: x.currency.strip() != "" and x.revenue.strip() != "" and x.idfa.strip() != "00000000-0000-0000-0000-000000000000",
                   items)
    items = sorted(items, key=lambda x: x.rec_timestamp)
    return items


if __name__ == "__main__":
    pass
    # print(os.path.dirname(os.path.abspath("__file__")))

    # get_target_by_key(client, "AppSDK", "1000000906777038")

    # source = "AppSDK"
    # transaction_id = "1000000906777038"
    # property_dict = {
    #     "idfv": "E7087037-5BB1-4F46-BDE6-B8B6581D6C6B",
    #     "product_id": "unicorn.slime.premium.weekly.8.99.promo.01",
    #     "price": "\u00a528.00",
    #     "currency": "CNY",
    #     "idfa": "FA4EEEE2-41EB-4B49-B122-0705A7D83DE2",
    #     "os": "13.4.1",
    #     "appsflyer_id": "1629191854863-7087037",
    # }
    # print(record_data(client, source, transaction_id, property_dict))

    # source = "AppleNotification"
    # transaction_id = "1000000906777038"
    # property_dict = {"af_content_type": "DID_CHANGE_RENEWAL_PREF",
    #                  "af_content_id": "unicorn.slime.premium.weekly.8.99.promo.01",
    #                  "renewal": True}
    # print(record_data(client, source, transaction_id, property_dict))
