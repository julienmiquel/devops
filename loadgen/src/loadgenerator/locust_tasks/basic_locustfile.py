#!/usr/bin/env python

# Copyright 2020 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import random
from locust import task, HttpUser, TaskSet

#{"BTC":38509,"ETH":2683,"EUR":1.12,"LTC":109,"USD":1,"XMR":145}

currencies = [
    'BTC',
    'ETH',
    'EUR',
    'LTC',
    'USD',
    'XMR'
    ]

donateurs = [
    "Tony Stark",
    "Julien M",
    "Bob Morane",
    "Sarah Conor",
]

donationsId = [
    1,
    2,
    3,
    4,
]

# Define specific frontend actions.

@task
def statistics(l):
    l.client.get("/statistics")

@task
def getalldonations(l):
    l.client.get("/donations")

@task
def getonedonation(l):
    l.client.get("/donations/61fa5d2d672226469b8c1400" )

@task
def makedonation(l):
    donateur = random.choice(donateurs) + "-" + str(random.randint(0, 10000))
    currency = random.choice(currencies)

    headers = {'content-type': 'application/json'}

    response = l.client.post("/donation", {
        'donatorName': donateur,
        'amount': random.choice([1,2,3,4,5,10]) * 100,
        "moneyType": currency
        }, 
        headers=headers)
    print("result\n")
    print(response)


# LocustIO TaskSet classes defining detailed user behaviors.

class PurchasingBehavior(TaskSet):

    def on_start(self):
        print("visit index page")
        #index(self) Not needed for API
        statistics(self)

    tasks = { statistics: 1,
        makedonation: 2,
        getalldonations: 1,
        }


class BrowsingBehavior(TaskSet):

    def on_start(self):
        print("visit index page")
        #index(self) Not needed for API
        statistics(self)

    tasks = {
        makedonation: 10,
        getalldonations: 1,
        statistics: 10 }

# LocustIO Locust classes defining general user scenarios.

class PurchasingUser(HttpUser):
    '''
    User that browses products, adds to cart, and purchases via checkout.
    '''
    tasks = [PurchasingBehavior]
    min_wait = 1000
    max_wait = 10000


class BrowsingUser(HttpUser):
    '''
    User that only browses products.
    '''
    tasks = [BrowsingBehavior]
    min_wait = 1000
    max_wait = 10000
