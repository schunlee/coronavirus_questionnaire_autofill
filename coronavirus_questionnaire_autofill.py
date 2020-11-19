#! /usr/bin/env python
# -*- coding: utf-8 -*-
import json
import random

import requests
from requests_toolbelt import MultipartEncoder

__author__ = "bill.li"

if __name__ == '__main__':
    pass
    CHOICES = ["36.5", "36.5"]

    headers = {"Accept": "application/json, text/plain, */*",
               "User-Agent": "Mozilla/5.0 (Linux; Android 9; SEA-AL10 Build/HUAWEISEA-AL1001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/6.2 TBS/045008 Mobile Safari/537.36 wxwork/3.0.10 MicroMessenger/7.0.1 NetType/WIFI Language/zh",
               "Referer": "https://doc.weixin.qq.com/",
               "Cookie": "wwapp.deviceid=10000581913976GF; wwapp.cst=FF53D6D0B03DAA8DEFB1759A47846B516DD86A8C78D69A54B4A5B00E2DBF6FF3871EBFF6C8A934A8AF01BBD6D42CFBD6; wwapp.vid=1688851310447801; wwapp.st=38AF8F9B9B1E4E36716D2CEE67EBD22817A11F418648E154631FE270C2FAA476B361969AA010665A271408287616BD328E1051A03BB9D7EA8A988F9508DA0FA55B2F31A42F772A71C7158E31417421D7606B3D656764ACD5BF949BB1587F61F7D9C49B06C63B417EC4CF54BB77F4CFFF11B7F7896FB77673584B9FBE50767485; wwapp.session=4Cdjzz%2FD9PCFIP%2Fxeix9S7HfUF2FoYcRScBGb%2BbkOQ2hDV39fp8FIoqlHZiKuG0MUovC8MYLUaz%2Bw%2BgpaaD3hJHfjPHU0bb07yTjChvdgUvJ8wW59%2FWPJwPo0fpZ42F9MdkathAOrjm4GhM5u4arrzM54CGY8Cgrf3ASiLiS67An3TZ%2BhaOJDzvYJLZQmTmGM4sIqM4Mg770EMsxfpGb4MGJRooyGM0DHZlSZF5Kra9rScaZt3O2J62CcGVjcGLQ; tdoc_vid=1688851310447801; tdoc_sid=ALloWgAMOGoGcFN4AFZQdAAA; tdoc_skey=1688851310447801&9c7f0113dddeeab3156276412c33f556CAESIMPVy6EzVvqLBe54Cjk0rklYGCe9iQYQLkoL251GYCeJ; xm_data_ticket=CAESIMPVy6EzVvqLBe54Cjk0rklYGCe9iQYQLkoL251GYCeJ",
               "X-Requested-With": "com.tencent.wework",
               "Q-UA2": "QV=3&PL=ADR&PR=TRD&PP=com.tencent.wework&PPVN=3.0.10&TBSVC=43722&CO=BK&COVC=045008&PB=GE&VE=GA&DE=PHONE&CHID=0&LCID=9422&MO= SEA-AL10 &RL=1080*2259&OS=9&API=28",
               "Q-GUID": "04f3e4d1eed255dea47a4dc913b788cb",
               "Q-Auth": "31045b957cf33acf31e40be2f3e71c5217597676a9729f1b"
               }
    boundary = "----WebKitFormBoundaryR9bXBenH8x7wFC9C"

    # to get recent form id
    data_to_upload = {
        'source': (None, '0'),
        'we_room_id': (None, ''),
    }
    encode_data = MultipartEncoder(data_to_upload, boundary=boundary)
    headers["Content-Type"] = encode_data.content_type
    resp = requests.post("https://doc.weixin.qq.com/form/healthformlist", data=encode_data.to_string(),
                         headers=headers).json()
    form_id = resp["body"]["form_items"][0]["form_id"]

    # auto fill in questionnaire
    json_data = {"items": [{"question_id": 1, "text_reply": "{NAME}", "option_reply": []},
                           {"question_id": 2, "text_reply": "", "option_reply": ["1"]},
                           {"question_id": 3, "text_reply": "", "option_reply": ["4"]},
                           {"question_id": 4, "text_reply": random.choice(CHOICES), "option_reply": []},
                           {"question_id": 5, "text_reply": "", "option_reply": ["1"]}]}

    data_to_upload = {
        'type': (None, '2'),
        'form_id': (None, form_id),
        'form_reply': (None, json.dumps(json_data)),
        'f': (None, "json")
    }
    encode_data = MultipartEncoder(data_to_upload, boundary=boundary)
    headers["Content-Type"] = encode_data.content_type
    resp = requests.post("https://doc.weixin.qq.com/form/share?f=json", data=encode_data.to_string(),
                         headers=headers).json()
