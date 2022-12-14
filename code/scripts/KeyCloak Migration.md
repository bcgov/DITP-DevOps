# KeyCloak Migration

## Resources

The [bcgov/trust-over-ip-configurations](https://github.com/bcgov/trust-over-ip-configurations) manage script contains commands for updating the registration of `vc-authn` clients.

The two main commands you will use are:

`./manage -p default -e <env> getAuthClient`
  - To view existing `vc-authn` clients and their settings.

`./manage -p default -e <env> updateAuthClient`
  - To update existing `vc-authn` clients and their settings.

The [manage](./manage) script in this directory was created to copy IDPs and their associated mappers from one KeyCloak environment to another.  You will need to setup a service account in each realm in order to use the scripts.

## Basic Steps Migrating from the Silver to Gold Realms

One environment at a time:
1. Copy over the `BC Services Card` (`bcsc`) and `Verifiable Credential` (`verifiable-credential`) IDPs and mappers.
2. Create the `vc_authn` client scope.
3. One KeyCloak client and application component at a time
   1. Test the application component to ensure you know how it functions before you migrate it.
   2. Export the client from one realm and import it into the new one.
   3. Disable the Client in old realm once it has been imported.
   4. Add `vc_authn` scope to the client's `Assigned Default Client Scopes`.  You will run into authentication and invalid profile issues otherwise.
   5. In the application's configurations
      1. Find and replace the realm references.  For example:
         - `oidc.gov.bc.ca` => `loginproxy.gov.bc.ca`
         - `gzyg46lx` => `digitaltrust-citz`
   6. Updated the `vc-authn` client registration using the [bcgov/trust-over-ip-configurations](https://github.com/bcgov/trust-over-ip-configurations) manage script if needed.  For example:
         - `./manage -p default -e dev updateAuthClient gzyg46lx-dev https://dev.loginproxy.gov.bc.ca/auth/realms/digitaltrust-citz/broker/verifiable-credential/endpoint`
   7. Test each application component before moving onto the next.
