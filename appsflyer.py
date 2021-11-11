#!/usr/bin/env python
# coding=utf-8
import json

import requests

DEV_KEY = "MYbWHPCkTsaE4kH75yuaB5"


def send_server_to_server(app_id, appsflyer_id, currency, idfa, idfv, os, bundle_id, revenue, af_content_type,
                          af_content_id, renewal):
    url = "https://api2.appsflyer.com/inappevent/id{}".format(app_id)
    event_value = {
        "af_revenue": revenue,
        "af_content_type": af_content_type,
        "af_content_id": af_content_id,
        "renewal": renewal
    }
    payload = {"appsflyer_id": appsflyer_id,
               "eventName": "af_subscribe",
               "bundleIdentifier": bundle_id,
               "transaction_id": "1000000906777038",
               "eventValue": json.dumps(event_value),
               }
    if idfa != "00000000-0000-0000-0000-000000000000":
        payload.update({"idfa": idfa})
    if idfv:
        payload.update({"idfv": idfv})
    if os:
        payload.update({"os": os})
    if currency:
        payload.update({"eventCurrency": currency})

    headers = {
        'authentication': DEV_KEY,
        'Content-Type': 'application/json'
    }
    response = requests.request("POST", url, headers=headers, data=json.dumps(payload))

    return response.text.encode('utf8')


if __name__ == "__main__":
    pass
    send_server_to_server("1448228271", "1629191854863-7087037", "CNY", "FA4EEEE2-41EB-4B49-B122-0705A7D83DE2",
                          "E7087037-5BB1-4F46-BDE6-B8B6581D6C6B", "13.4.1",
                          "com.shakeitmediainc.unicorn.slime.girl.games.for.free", "70", "Auto-Renewable Subscription",
                          "unicorn.slime.premium.weekly.5.99.promo.07", False)
