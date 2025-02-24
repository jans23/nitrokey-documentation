Accessing a NetHSM using the PKCS#11 driver
===========================================

.. contents:: :local:

1. Download the `PKCS#11 driver <https://github.com/Nitrokey/nethsm-pkcs11>`__ for NetHSM.
2. Modify the configuration file ``p11nethsm-config.yaml`` according to
   your setup (e.g. address, operator name) and store it in ``$HOME/.nitrokey``, ``/etc/nitrokey/``,
   or in the folder where your application is executed.

Decrypting
----------

After creating a key (here: ID 42) with the according mechanism, you can use it for decryption:

::

   $ KEYID=42
   $ HEXID=$(echo ${KEYID}'\c' | xxd -ps)
   $ curl -s -u operator:opPassphrase -X GET \
     https://nethsmdemo.nitrokey.com/api/v1/keys/$KEYID/public.pem -o _public.pem
   $ echo 'NetHSM rulez!' | openssl pkeyutl -encrypt -pubin -inkey _public.pem \
     -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha512 \
     -pkeyopt rsa_mgf1_md:sha512 -out _data.crypt
   $ pkcs11-tool --module p11nethsm.so -v -p opPassphrase --decrypt \
     --mechanism RSA-PKCS-OAEP --input-file _data.crypt --id $HEXID \
     --hash-algorithm SHA512

Signing
-------

After creating a key (here: ID 23) with the according mechanism, you can use it for decryption:

::

   $ KEYID=23
   $ HEXID=$(echo ${KEYID}'\c' | xxd -ps)
   $ curl -s -u operator:opPassphrase -X GET \
     https://nethsmdemo.nitrokey.com/api/v1/keys/$KEYID/public.pem -o _public.pem
   $ echo 'NetHSM rulez!' | pkcs11-tool --module p11nethsm.so -v -p opPassphrase \
     --sign --mechanism SHA512-RSA-PKCS-PSS --output-file _data.sig --id $HEXID
   $ echo 'NetHSM rulez!' | openssl dgst -keyform PEM -verify _public.pem -sha512 \
     -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 -signature _data.sig

