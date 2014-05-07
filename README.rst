====================================================
Project using Sinatra to tests services availability
====================================================

If this project isn't useful for you, use other. Don't bother me.


Deployment
==========

Run bundle to install requirements

.. code-block:: bash

   bundle install

You can launch the service with foreman or with directly with ruby:

.. code-block:: bash

   bundle exec ruby app.rb

Run bundle to install requirements

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
