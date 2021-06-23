# Update frameworks

## License
[MIT](https://choosealicense.com/licenses/mit/)


Add this file to compile and add to local host.




    #if targetEnvironment(simulator)
    let localDomain = "127.0.0.1"
    #else
    let localDomain = "Kyles-MacBook-Pro.local"
    #endif

     Go to mac System Preferences -> Sharing
     See on that screen it says:
     "Computers on your local network can access your computer at:"
     Below that is the name you should set to `localDomain` for the else case. Simulator should be 127.0.0.1.


