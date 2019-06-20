# Daily Gemstone

A framework for daily logins using [Semaphore CI](https://semaphoreci.com)

Walkthrough:
1. sign up for a Semaphore CI account
2. fork this repo or whatever
3. add your `login.dat` to your ]Semaphore CI secrets](https://docs.semaphoreci.com/article/66-environment-variables-and-secrets)
4. trigger some builds

You probably will want to set up a [cron schedule](https://docs.semaphoreci.com/article/52-projects-yaml-reference#schedulers)

You'll need to [install the `sem` cli tool](https://docs.semaphoreci.com/article/53-sem-reference) to make your life easier.
