import requests

from saml2 import (
    BINDING_HTTP_POST,
    BINDING_HTTP_REDIRECT,
)
from saml2.client import Saml2Client
from saml2.config import Config as Saml2Config

from zou.app import config


def saml_client_for(metadata_source):
    """
    Given a metadata URL or file path, return a SAML client configuration.
    The metadata_source can be:
      - A URL (http:// or https://) - fetched via HTTP
      - A file path (starts with /) - read from local filesystem
    """
    acs_url = (
        f"{config.DOMAIN_PROTOCOL}://{config.DOMAIN_NAME}/api/auth/saml/sso"
    )

    # Load metadata from file or URL
    if metadata_source.startswith("/"):
        with open(metadata_source, "r") as f:
            metadata_xml = f.read()
    else:
        rv = requests.get(metadata_source)
        metadata_xml = rv.text

    settings = {
        "entityid": f"{config.DOMAIN_PROTOCOL}://{config.DOMAIN_NAME}/api/auth/saml/login",
        "metadata": {"inline": [metadata_xml]},
        "service": {
            "sp": {
                "endpoints": {
                    "assertion_consumer_service": [
                        (acs_url, BINDING_HTTP_REDIRECT),
                        (acs_url, BINDING_HTTP_POST),
                    ],
                },
                # Don't verify that the incoming requests originate from us via
                # the built-in cache for authn request ids in pysaml2
                "allow_unsolicited": True,
                # Don't sign authn requests, since signed requests only make
                # sense in a situation where you control both the SP and IdP
                "authn_requests_signed": False,
                "logout_requests_signed": True,
                "want_assertions_signed": True,
                "want_response_signed": False,
            },
        },
    }
    spConfig = Saml2Config()
    spConfig.load(settings)
    spConfig.allow_unknown_attributes = True
    saml_client = Saml2Client(config=spConfig)
    return saml_client
