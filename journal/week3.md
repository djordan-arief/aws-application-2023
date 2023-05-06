# Week 3 — Decentralized Authentication

# github instruction link
https://github.com/omenking/aws-bootcamp-cruddur-2023/blob/week-3/journal/week3.md

# AWS Cognito security best practice
- It should only be in the AWS Region that you are legally allowed to be holding user data in
- AWS CloudTrail is enabled & monitored to trigger alerts on malicious Cognito behaviour
- Security tests of the application through penetration testing
- Access token scope should be limited

# AWS Cognito implementation
Configure a user pool in AWS

# Install AWS Amplify
npm i aws-amplify --save

# configure amplify

# set the env var in the docker file and app.js
REACT_APP_AWS_PROJECT_REGION=${YOUR_AWS_PROJECT_REGION}
REACT_APP_AWS_COGNITO_REGION=${YOUR_COGNITO_REGION}\
REACT_APP_AWS_USER_POOLS_ID=${YOUR_USER_POOL_ID}\
REACT_APP_CLIENT_ID=${YOUR_APP_CLIENT_ID}\

# Conditionally show components based on logged in or logged out



# Add aws amplify to the sign in page
in SigninPage.js:

import { Auth } from 'aws-amplify';

const onsubmit = async (event) => {
    setErrors("");
    event.preventDefault();
    try {
      Auth.signIn(username, password)
        .then((user) => {
          localStorage.setItem(
            "access_token",
            user.signInUserSession.accessToken.jwtToken
          );
          window.location.href = "/";
        })
        .catch((err) => {
          console.log("Error!", err);
        });
    } catch (error) {
      if (error.code == "UserNotConfirmedException") {
        window.location.href = "/confirm";
      }
      setErrors("")(error.message);
    }
    return false;
};

# codes for the sign out
import { Auth } from 'aws-amplify';

const signOut = async () => {
    try {
        await Auth.signOut({ global: true });
        window.location.href = "/"
    } catch (error) {
        console.log('error signing out: ', error);
    }
  }


# create a user in the aws cognito user pool 
go to the aws website and go to the aws cognito management console
to create a user

# to change the status of force change password to confirmed
aws cognito-idp admin-set-user-password \
  --user-pool-id <your-user-pool-id> \
  --username <username> \
  --password <password> \
  --permanent


log into your account using your user credentials created in the user pool

# use a custom sign up page
import the auth component from the aws-amplify:
import { Auth } from "aws-amplify";

implement a onsubmit function: 

const onsubmit = async (event) => {
    event.preventDefault();
    setErrors('')
    try {
        const { user } = await Auth.signUp({
          username: email,
          password: password,
          attributes: {
              name: name,
              email: email,
          },
          autoSignIn: { // optional - enables auto sign in after user is confirmed
              enabled: true,
          }
        });
        console.log(user);
        window.location.href = `/confirm?email=${email}`
    } catch (error) {
        console.log(error);
        setErrors(error.message)
    }
    return false
  }


# use a custom confirmation page
add these lines of code: 

import { Auth } from "aws-amplify";

const resend_code = async (event) => {
    setErrors("");
    try {
      await Auth.resendSignUp(email);
      console.log("code resent successfully");
      setCodeSent(true);
    } catch (err) {
      // does not return a code
      // does cognito always return english
      // for this to be an okay match?
      console.log(err);
      if (err.message == "Username cannot be empty") {
        setErrors(
          "You need to provide an email in order to send Resend Activiation Code"
        );
      } else if (err.message == "Username/client id combination not found.") {
        setErrors("Email is invalid or cannot be found.");
      }
    }
  };

const onsubmit = async (event) => {
    event.preventDefault();
    setCognitoErrors("");
    try {
      await Auth.confirmSignUp(email, code);
      window.location.href = "/";
    } catch (error) {
      setCognitoErrors(error.message);
    }
    return false;
  };

# use custome recovery page
add these lines of code:
import { Auth } from 'aws-amplify';

const onsubmit_send_code = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  Auth.forgotPassword(username)
  .then((data) => setFormState('confirm_code') )
  .catch((err) => setCognitoErrors(err.message) );
  return false
}

const onsubmit_confirm_code = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  if (password == passwordAgain){
    Auth.forgotPasswordSubmit(username, code, password)
    .then((data) => setFormState('success'))
    .catch((err) => setCognitoErrors(err.message) );
  } else {
    setCognitoErrors('Passwords do not match')
  }
  return false
}


# Cognito JWT server token verification
Add the Authorization header to the request to the backend url

headers: {
  Authorization: `Bearer ${localStorage.getItem("access_token")}`
}

# set the CORS
cors = CORS(
  app, 
  resources={r"/api/*": {"origins": origins}},
  headers=['Content-Type', 'Authorization'], 
  expose_headers='Authorization',
  methods="OPTIONS,GET,HEAD,POST"
)

Note: set the origins to the FRONTEND_URL and BACKEND_URL. The origins parameter is used to specify which domains are allowed to make requests to the API.