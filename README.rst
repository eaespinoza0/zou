.. figure:: https://zou.cg-wire.com/kitsu.png
   :alt: Kitsu Logo

Zou, the Kitsu API is the memory of your animation production
-------------------------------------------------------------

The Kitsu API allows to store and manage the data of your animation/VFX
production. Through it, you can link all the tools of your pipeline and make
sure they are all synchronized.

A dedicated Python client, `Gazu <https://gazu.cg-wire.com>`_, allows users to
integrate Zou into the tools. 

|CI badge| |Downloads badge| |Discord badge|

Features
~~~~~~~~

Zou can:

-  Store production data, such as projects, shots, assets, tasks, and file metadata.
-  Track the progress of your artists
-  Store preview files and version them
-  Provide folder and file paths for any task
-  Import and Export data to CSV files
-  Publish an event stream of changes

Quick Start (Docker)
~~~~~~~~~~~~~~~~~~~~

1. Setup secrets
^^^^^^^^^^^^^^^^

.. code:: bash

    mkdir -p secrets

    # Required
    openssl rand -hex 32 > secrets/secret_key.txt
    echo "your-db-password" > secrets/db_password.txt

    # Optional (create empty if not using)
    touch secrets/mail_password.txt
    touch secrets/indexer_key.txt

    chmod 600 secrets/*.txt

See `SECRETS.md <SECRETS.md>`_ for detailed secret management.

2. Start services
^^^^^^^^^^^^^^^^^

.. code:: bash

    docker compose up -d

3. Initialize database (first time only)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: bash

    docker compose --profile init up zou-init

4. Create admin user
^^^^^^^^^^^^^^^^^^^^

.. code:: bash

    docker compose exec zou /app/entrypoint.sh zou create-admin admin@example.com --password 'your-password'

5. Access API
^^^^^^^^^^^^^

.. code:: bash

    curl http://localhost:5000/
    # {"api":"Zou","version":"1.0.3"}

Services
~~~~~~~~

============  ============================  ======
Service       Description                   Port
============  ============================  ======
zou           Main API server               5000
zou-events    WebSocket events (optional)   5001
postgres      Database                      internal
redis         Cache                         internal
meilisearch   Search (optional)             7700
============  ============================  ======

Optional Components
~~~~~~~~~~~~~~~~~~~

.. code:: bash

    # WebSocket events server
    docker compose --profile events up -d

    # Full-text search (set INDEXER_KEY first)
    docker compose --profile search up -d

    # Both
    docker compose --profile events --profile search up -d

Building Images
~~~~~~~~~~~~~~~

.. code:: bash

    # Build locally
    docker compose build

    # Build and tag for registry
    docker build -t your-registry.com/zou:v1.0.0 .
    docker push your-registry.com/zou:v1.0.0

Using Pre-built Images
~~~~~~~~~~~~~~~~~~~~~~

Set ``ZOU_IMAGE`` in ``.env``:

.. code:: bash

    echo "ZOU_IMAGE=your-registry.com/zou:v1.0.0" >> .env
    docker compose up -d

Commands
~~~~~~~~

.. code:: bash

    # View logs
    docker compose logs -f zou

    # Check status
    docker compose ps

    # Stop services
    docker compose down

    # Stop and remove data
    docker compose down -v

Configuration
~~~~~~~~~~~~~

Environment variables can be set in ``.env``. See ``env.sample`` for options.

Key settings:

- ``ZOU_PORT`` - API port (default: 5000)
- ``ZOU_EVENTS_PORT`` - Events port (default: 5001)
- ``DOMAIN_NAME`` - Your domain for email links
- ``MAIL_*`` - Email configuration

Documentation
~~~~~~~~~~~~~

- API Docs: `https://zou.cg-wire.com/ <https://zou.cg-wire.com>`__
- API Spec: `https://api-docs.kitsu.cloud/ <https://api-docs.kitsu.cloud>`__
- Python Client: `Gazu <https://gazu.cg-wire.com>`_

Contributing
------------

Contributions are welcomed so long as the `C4
contract <https://rfc.zeromq.org/spec:42/C4>`__ is respected.

Zou is based on Python and the `Flask <http://flask.pocoo.org/>`__
framework.

You can use the pre-commit hook for Black (a Python code formatter) before
committing:

.. code:: bash

    pip install pre-commit
    pre-commit install

Instructions for setting up a development environment are available in
`the documentation <https://zou.cg-wire.com/development/>`__


Contributors
------------

* @aboellinger (Xilam/Spa)
* @BigRoy (Colorbleed)
* @EvanBldy (CGWire) - *maintainer*
* @ex5 (Blender Studio)
* @flablog (Les Fées Spéciales)
* @frankrousseau (CGWire) - *maintainer*
* @kaamaurice (Tchak)
* @g-Lul (TNZPV)
* @pilou (Freelancer)
* @LedruRollin (Cube-Xilam)
* @mathbou (Zag)
* @manuelrais (TNZPV)
* @NehmatH (CGWire)
* @pcharmoille (Unit Image)
* @Tilix4 (Normaal)

About authors
~~~~~~~~~~~~~

Kitsu is written by CGWire, a company based in France. We help with animation and
VFX studios to collaborate better through efficient tooling. We already work
with more than 70 studios around the world.

Visit `cg-wire.com <https://cg-wire.com>`__ for more information.

|CGWire Logo|

.. |CI badge| image:: https://github.com/cgwire/zou/actions/workflows/ci.yml/badge.svg
   :target: https://github.com/cgwire/zou/actions/workflows/ci.yml
.. |Gitter badge| image:: https://badges.gitter.im/cgwire/Lobby.png
   :target: https://gitter.im/cgwire/Lobby
.. |CGWire Logo| image:: https://zou.cg-wire.com/cgwire.png
   :target: https://cgwire.com
.. |Downloads badge| image:: https://static.pepy.tech/personalized-badge/zou?period=total&units=international_system&left_color=grey&right_color=orange&left_text=Downloads
   :target: https://pepy.tech/project/zou
.. |Discord badge| image:: https://badgen.net/badge/icon/discord?icon=discord&label
   :target: https://discord.com/invite/VbCxtKN
