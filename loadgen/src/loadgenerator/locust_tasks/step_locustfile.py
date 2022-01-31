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

import math
import random
from locust import task, HttpUser, TaskSet, LoadTestShape


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
def postalldonations(l):
    l.client.post("/donations")

@task
def getalldonations(l):
    l.client.get("/donations")

@task
def getonedonation(l):
    l.client.get("/donations/DONATION_ID?=" + random.choice(donationsId))

@task
def makedonation(l):
    donateur = random.choice(donateurs)
    currency = random.choice(currencies)

    l.client.post("/donation", {
        'donatorName': donateur,
        'amount': random.choice([1,2,3,4,5,10]) * 100,
        "moneyType": currency
        }
        )

@task
def makedonationtest(l):

    l.client.post("/donation", 
    {
        'donatorName': "Test user",
        'amount': 9999,
        "moneyType": "€"
        }
    )

# LocustIO TaskSet classes defining detailed user behaviors.

class PurchasingBehavior(TaskSet):

    def on_start(self):
        index(self)

    tasks = {index: 1,
        makedonationtest: 1,
        getalldonations: 1,
        makedonation: 5,
        postalldonations: 2,
        getonedonation: 1
        }



class BrowsingDonation(TaskSet):

    def on_start(self):
        index(self)

    tasks = {
        index: 5,
        getalldonations: 10
        }

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
    tasks = [BrowsingDonation]
    min_wait = 1000
    max_wait = 10000

class StepLoadShape(LoadTestShape):
    """
    A step load shape
    Keyword arguments:
        step_time -- Time between steps
        step_load -- User increase amount at each step
        spawn_rate -- Users to stop/start per second at every step
        time_limit -- Time limit in seconds
    """

    step_time = 30
    step_load = 10
    spawn_rate = 10
    time_limit = 300 # 5 minutes = 100 locusts total

    def tick(self):
        run_time = self.get_run_time()

        if run_time > self.time_limit:
            return None

        current_step = math.floor(run_time / self.step_time) + 1
        return (current_step * self.step_load, self.spawn_rate)
