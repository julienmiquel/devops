#!/usr/bin/env python

# Copyright 2021 Google Inc. All rights reserved.
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
from locust import task, between, HttpUser

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
    "john malkovich"
]



class BasicHomePageViewingUser(HttpUser):
    """
    A user that simply visits the home page.
    This load pattern is useful for SRE Recipes that want to expose
    potential bugs or high page load latency in the frontend.
    """
    sre_recipe_user_identifier = "BasicHomePageViewingUser"

    # wait between 1 and 10 seconds after each task
    wait_time = between(1, 10)

    @task
    def visit_home_page(self):
        print("To be completed during the hackathon ")
        #self.client.get("/")


class BasicPurchasingUser(HttpUser):
    """
    A user behavior flow that generates loads to simulate the minimal set
    of behaviors needed for checkout. This load pattern is useful for SRE
    Recipes that want to expose potential bugs in cart and checkout services.
    """
    # User Identifier for use by SRE Recipes
    sre_recipe_user_identifier = "BasicPurchasingUser"

    # wait between 1 and 10 seconds after each task
    wait_time = between(1, 10)

    @task
    def buy_random_product_and_checkout(self):
        # visit home page
        print("To be completed during the hackathon ")
        #self.client.get("/")


        donateur = random.choice(donateurs) + "-sre-test-" + str(random.randint(0, 10000))
        currency = random.choice(currencies)

        res = self.client.post("/donation", {
            'donatorName': donateur,
            'amount': random.choice([1,2,3,4,5,10]),
            "moneyType": currency
            }
            )

        print(res)
        alldonations = self.client.get("/donations")
        
        print(alldonations)
        #self.client.get("/donations/DONATION_ID?=" + random.choice(donationsId))

