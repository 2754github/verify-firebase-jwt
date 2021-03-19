# verify-firebase-jwt

A simple Ruby implementation to [verify firebase jwt](https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library).

You can use the verified uid immediately on your Rails app! ⬇️

```ruby
uid = FirebaseAuth.uid(firebase_jwt)
```

Main code is [here](https://github.com/2754github/verify-firebase-jwt/blob/main/lib/verify/firebase/jwt.rb). 👈

## Announcements

⚠️ This gem is currently in beta and should be used in production with caution! 🙇‍♂️

## Install

Add the following to your `Gemfile`:

```ruby
gem 'verify-firebase-jwt'
```

And run `bundle install`

## Configure

### Initialize the class within your `config/initializers/firebase_auth.rb`:

```ruby
require 'verify/firebase/jwt'

::FirebaseAuth = FirebaseAuth.new(ENV["FIREBASE_PROJECT_ID"])
```

> Note: Add the FIREBASE_PROJECT_ID to your `.env`.

### Set up your cache store

[Here](https://guides.rubyonrails.org/caching_with_rails.html#cache-stores) is a good reference.

> Note: The cache store is used to cache the certificates fetched from Google. 😌

## Usage

### Frontend:

```js
firebase
  .auth()
  .currentUser.getIdToken(/* forceRefresh */ true)
  .then(function (idToken) {
    // Send token to your backend via HTTPS
    // ...
  })
  .catch(function (error) {
    // Handle error
  });
```

> Note: [Here](https://firebase.google.com/docs/auth/admin/verify-id-tokens#retrieve_id_tokens_on_clients) is the official Firebase documentation.

### Backend (Your Rails app):

```ruby
# firebase_jwt = "eyJhbGciOiJfzKic... <= Received from Frontend

begin
  uid = FirebaseAuth.uid(firebase_jwt)
rescue => e
  class FirebaseAuthError < StandardError; end
  # class FirebaseAuthError < GraphQL::ExecutionError; end
  raise FirebaseAuthError.new("#{e.class} (#{e.message})")
end

puts uid # => Hdh4pa2YdlGCMyJv9rORNkIjNju2
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/2754github/verify-firebase-jwt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/2754github/verify-firebase-jwt/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). For more details please refer to [license](https://github.com/2754github/verify-firebase-jwt/blob/main/LICENSE.txt).

## Code of Conduct

Everyone interacting in the Verify::Firebase::Jwt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/2754github/verify-firebase-jwt/blob/main/CODE_OF_CONDUCT.md).
