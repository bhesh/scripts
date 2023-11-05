scripts
=======

Helpful scripts for generating X.509 test data

## Usage

### Test data

Generates various keys, CAs, certificate requests, certificates, CRLs, ocsp requests, and ocsp responses.

```bash
$ ./generate-test-data.sh
```

### Real data

Does the following:
- Grabs the TLS certificate chain of a real website
- Creates an ocsp request for each certificate in the chain
- Sends the request and retrieves the response from the responder specified in the OCSP AIA

```bash
$ ./generate-real-ocsp.sh -H <hostname> -p <port> [-s <SNI>]
```

Runs `generate-real-ocsp.sh` for several of the most visited sites

```bash
$ ./generate-read-data.sh
```

### Other

There are other several helper scripts that do single-job tasks that are used in the above `generate-*` scripts.

## License

Either of the following:

- [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
- [MIT license](http://opensource.org/licenses/MIT)
