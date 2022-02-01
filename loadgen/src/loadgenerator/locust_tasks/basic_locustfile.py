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


currencies = [
    '€',
    '$',
    '£'
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
def index(l):
    l.client.get("/")

@task
def getalldonation(l):
    l.client.post("/donations")

@task
def getonedonation(l):
    l.client.get("/donations/DONATION_ID?=" + str(random.choice(donationsId)))

@task
def makedonation(l):
    donateur = random.choice(donateurs)
    currency = random.choice(currencies)

    l.client.post("/donation", {
        'donatorName': donateur,
        'amount': random.choice([1,2,3,4,5,10]),
        "moneyType": currency
        }
        )


# LocustIO TaskSet classes defining detailed user behaviors.

class PurchasingBehavior(TaskSet):

    def on_start(self):
        index(self)

    tasks = {index: 1,
        makedonation: 2,
        getalldonation: 2,
        getonedonation: 1
        }


class BrowsingBehavior(TaskSet):

    def on_start(self):
        index(self)

    tasks = {index: 5,
        makedonation: 10,
        getalldonation: 1}

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
