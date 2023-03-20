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

## Migrating more complicated Clients from the Silver to Gold Realms

When a client has custom mappings, and roles that are related to other client services accounts and even groups the migration process is a little more complicated.

1. Use `./manage copyClientAndRoles` to migrate the clients from one realm to the other.
2. Use the KeyCloak Export feature on the source realm to export all resources.
3. Use the KeyCloak Import feature on the destination realm to import the realm's Roles and Groups.  Select `Skip` from the `If a resource exists`.
    - This will import the Roles and Groups that do not already exist.
4. To repair any service account role mappings to client roles.  Use the KeyCloak Import feature on the destination realm again to import the realm's Users.  Select `Skip` from the `If a resource exists`.
   1. Run the import.
   2. You may need to edit the export file and delete service account users from the `User` section depending on the Clients you have decided to import.
   3. Once the import runs, review the list of skipped user accounts (it should be all of them).
   4. Edit the export file deleting users that you do not want to overwrite.
   5. Repeat steps 3 and 4 until the list only contains the user accounts that need to be updated.
   6. Run the import one last time selecting `Overwrite` from the `If a resource exists`.
   7. Review the client role membership of your affected clients.
