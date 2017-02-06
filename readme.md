#Cliper-Server
`Cliper` is an online clipboard sync tool.  
`Cliper-Server` is a component of Cliper.  

##Requirements

- DMD v2.071.2 or later
- DUB 1.0.0 or later

##Installation

```zsh
$ git clone https://github.com/alphaKAI/cliper-server
$ cd cliper-server
$ dub build
```

##Configuration
`Cliper-Server` can be configured with environment variable.  
You must set required values before use.  


|VALUE|Description|
|-----|-----------|
|CLIPER\_SERVER\_MONGO\_DSN|Scheme to connect to MongoDB, format is `"mongodb://user:password@host"`(This value is required, you can omit `user` and `password`, if you omit them, you can set the value as `"mongodb://host"` directory)|
|CLIPER\_SERVER\_PORT|Port number of `Cliper-Server`.(This value is optional, default port is `3017`)|


##License
Copyright (c) 2017, Akihiro Shoji  
`Cliper-Server` is released under the MIT License.  
Please see `LICENSE` for details.  
