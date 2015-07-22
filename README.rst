====================================================
Project using Sinatra to tests services availability
====================================================

If this project isn't useful for you, use other. Don't bother me.

This project have some heroku tasks that can be executed on heroku sheduler
environment.

Deployment
==========

Run bundle to install requirements

.. code-block:: bash

   bundle install

You can launch the service with foreman or with directly with ruby:

.. code-block:: bash

   bundle exec rackup config.ru


Proxy status
============

Create environment variables starting with PROXY_{proxy_name} pointing to your
proxy uri.

If you want to test a proxy called localhost with uri http://localhost:8999/

Create the environment and make it available:

.. code-block:: bash

   export PROXY_localhost=http://localhost:8999/


The test is available at this uri http://localhost:5000/proxy/localhost

That request returns 200 OK with the proxy IP if the proxy ip fine.

Otherwise:

- If the IP is the same that proxy ip: returns 409

- If ´PROXY_localhost´ variable doesn't exists, return 404


This service is going to use the the internal view /myip to test the proxy.
If you are using this server in localhost, you should set a property
called TESTING=1 in your environment. Then, the service ip.jsontest.com will be
used.


Protected area
==============

If you want to protect the tests you can add a user and password. The
application will be asking you by HTTP Auth Basic for a valid user when you
access to it.

This is made by environment.

The password is a hexdigest of sha256. You can get it with:

If you are in GNU based OS (linux):

.. code-block::

    echo -n 'yourpassword' | sha256sum

If you are in OSX:

.. code-block::

   echo -n 'youpassword' | shasum -a 256


Then, we need to add a user:

.. code-block::

   export HTTP_USER='youruser:yourpasswordhash'


Heroku Tasks
============

You can find instructions to enable heroku scheduler addon and how to use it
in https://devcenter.heroku.com/articles/scheduler


Heroku app restart
++++++++++++++++++

.. code-block::

   rake heroku:restart_app[$APP_NAME]


You really don't want this task, but sometimes you need to restart your app
process every night or similar. This task is aimed to that, that is restart the
app.

You need to define the environment var HEROKU_API_TOKEN. If you don't know how
to get that value, you can access to the follow link in the heroku api docs.

https://devcenter.heroku.com/articles/authentication#retrieving-the-api-token


Heroku shared env vars monitoring
+++++++++++++++++++++++++++++++++

If you use heroku and microservices architecture I'm sure you are suffering
when heroku addons env vars changed. Heroku sharing can help with this problem,
but not all addons providers allow Heroku sharing. For instance, This is the
case for OpenRedis addon.

This task help you to keep in sync the vars values. You need logentries or
something that allows you to send a "get" or "post" to a uri when your app is
start. When the your app start and the webhook is called, then a Job is going
to review shared env vars with the restarted app using values from a yaml
config file.


Available actions
-----------------

1. Send an email if values are differente (a email digest).

  .. code-block:

     HEROKU_SHARED_ENV_EMAIL_REPORT=true

2. Fix variable value if it changed.

  .. code-block:

     HEROKU_SHARED_ENV_PROPAGE_CHANGES=true



Available tasks
---------------


1. Review one app

  .. code-block::

     rake heroku:review_shared_env_app[$APP_NAME]


2. Review all apps in yaml file

  .. code-block::

     rake heroku:review_shared_env_all_apps


Webhook endpoint
----------------

not auth required

.. code-block::

   GET https://yourdomain.tld/hooks/review_env_vars/:app

   POST https://yourdomain.tld/hooks/review_env_vars/:app

The service always reply with status 201 and the same json.


Yaml file
---------

The yaml file should be accesible by a public url. That url is set in the
environment variable: **HEROKU_SHARED_ENV_FILE**

The file structure is as follow:

.. code-block::

   source_app_name:
     source_env_var_name:
        target_app: env_var_name
        target_app2: another_var_name
        target_app: env_var_name

   another_source_app:
     other_source_env_var_name:
        target_app: other_env_var_name



URL Monitoring
==============

Testing urls
++++++++++++

It will make call to the url with a time in betweem, if there is more than two
error it will send an email with the url and the error code.

The url are taken from a url accesible by a public url. One line per url. The
environment variable pointint to remote file is: **URL_TO_TESTED_URLS**

Available env variables:

.. code-block::

   TIMEOUT:                     5
   TIME_BEFORE_JOB:             2
   TIME_BETWEEN_DIFFERENT_URL:  1
   TIME_BETWEEN_SAME_URL:       60
   FAILURE_LOOP_COUNT:          5



Email Settings
==============

.. code-block::

   MAILGUN_SMTP_LOGIN:          a_smtp_user
   MAILGUN_SMTP_PASSWORD:       a_smtp_password
   MAILGUN_SMTP_PORT:           587
   MAILGUN_SMTP_SERVER:         a_smtp_server
   EMAIL_DOMAIN:                example.com
   EMAIL_FROM:                  no-reply@example.com
   EMAIL_SUBJECT_PREFIX:        [MONITORING]
   EMAIL_TO:                    someone@example.com
