# Stripe API Versioning

This document explains how versioning works in the Stripe API and how it will be implemented in the Crystal Stripe library.

## Versioning Overview

Stripe uses a versioning scheme to ensure that changes to the API don't break existing integrations. The versioning system works as follows:

- **Major Releases**: Named releases (e.g., "Acacia", "Basil") include changes that aren't backward-compatible with previous releases.
- **Monthly Releases**: Include only backward-compatible changes and use the same name as the last major release.

## Current Version

As of this writing, the current version is `2025-05-28.basil`.

## Version Format

Stripe API versions follow this format:
- Date in YYYY-MM-DD format
- Followed by a period and the major release name (e.g., "basil")

Examples:
- `2025-05-28.basil`
- `2024-10-15.acacia`

## Specifying API Version

### In HTTP Requests

You can specify the API version in your requests using the `Stripe-Version` header:

```
Stripe-Version: 2025-05-28.basil
```

### In the Crystal Library

The Crystal Stripe library will allow you to specify the API version when initializing the client:

```crystal
# Use a specific version
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  api_version: "2025-05-28.basil"
)

# Use the latest version (default)
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key"
)
```

## Account Default Version

Each Stripe account has a default version setting that is used when no version is specified in a request. You can set this default in the Stripe Dashboard under API Settings.

## Version Lifecycle

1. **Preview**: New versions may be available in preview before they become the default.
2. **Current**: The current version is the recommended version for new integrations.
3. **Legacy**: Older versions are supported for backward compatibility but may eventually be deprecated.

## Testing New Versions

Before upgrading to a new API version, you should test your integration against it:

1. Create a test environment that uses the new API version
2. Run your integration tests against this environment
3. Fix any issues that arise from the version change
4. Once everything works, upgrade your production environment

## Implementation in Crystal

The Crystal Stripe library will handle versioning as follows:

```crystal
module Stripe
  class Client
    # Default to the latest version if none is specified
    DEFAULT_API_VERSION = "2025-05-28.basil"
    
    def initialize(api_key : String, api_version : String? = nil, stripe_account : String? = nil)
      @api_key = api_key
      @api_version = api_version || DEFAULT_API_VERSION
      @stripe_account = stripe_account
    end
    
    # All requests will include the specified version
    def request(method, path, params = nil, headers = nil)
      default_headers = HTTP::Headers{
        "Authorization" => "Bearer #{@api_key}",
        "Stripe-Version" => @api_version
      }
      
      # Add Stripe-Account header if specified
      if @stripe_account
        default_headers["Stripe-Account"] = @stripe_account
      end
      
      # Merge with custom headers if provided
      if headers
        headers.each do |key, value|
          default_headers[key] = value
        end
      end
      
      # Make the request with the headers
      # ...
    end
  end
end
```

## Best Practices

1. **Specify a Version**: Always specify an API version in your code rather than relying on the account default.

2. **Stay Updated**: Regularly check the [API changelog](https://docs.stripe.com/changelog) for updates and new versions.

3. **Test Before Upgrading**: Test new API versions in a development environment before upgrading production.

4. **Version Consistency**: Use the same API version across all your integration points to ensure consistent behavior.

5. **Monitor Deprecations**: Pay attention to deprecation notices in the Stripe Dashboard and documentation.

## Handling Version Upgrades

When upgrading to a new API version:

1. Review the changelog for breaking changes
2. Update your code to handle any changes in response formats or parameters
3. Test thoroughly in a non-production environment
4. Deploy the changes to production
5. Monitor for any unexpected behavior

## Resources

- [Stripe API Changelog](https://docs.stripe.com/changelog)
- [Stripe API Versioning Documentation](https://docs.stripe.com/api/versioning)
