# Travis-CI

[官方文档](https://docs.travis-ci.com/)

免费Travis-CI（针对开源项目）：https://travis-ci.org

收费Travis-CI（针对私有和商业项目）：https://travis-ci.com

## 使用步骤

1. 登录 Travis CI 并对指定的项目启用。
2. 配置 .travis.yml ，参考官方文档。
3. push（或其他方式）触发Travis-CI。

## 实现工作流

1. 开发一些新功能，提交代码后自动构建出一个APK（可以是测试版，也可以是发布版）。
2. 将 APK 上传到 Github Release / [Fir.im](https://fir.im/) / [蒲公英](https://www.pgyer.com/)等。
3. 发出通知（邮件、消息等形式）。

### 关于发布签名安全

Android 项目发布需要证书文件、密码、别名、别名密码。无论是开源项目还是私有项目，任何时候都不应该将原始证书或密码放入代码库（原则上来讲证书和密码也不应该交于开发人员，而应该只能通过发布服务器进行编译）

Travis CI 为此提供了 2 种解决方案：

1. 对敏感信息、密码、证书等进行对称加密，在 CI 构建环境时解密。
2. 将密码等通过 Travis CI 控制台设置为构建时的环境变量。

个人倾向使用第二种方案，但 Travis CI 控制台无法上传文件，因此涉及到文件加密的部分，选择第一种方案。

#### 加密证书文件：

1. 本地安装 Travis CLI 命令行工具。

```shell
gem install travis
```

这一步如果遇到错误, 尝试加sudo，请升级一下 ruby 版本。


2. 命令行登录 Travis（第一次登录才要），并输入 GitHub 的用户名和密码。

针对免费版 https://travis-ci.org：

```shell
travis login --org
```

针对收费版Travis-C https://travis-ci.com：

```shell
travis login --pro
```

这一步如果遇到travis命令找不到, 尝试找到travis安装的bin目录，并配置上环境变量。

3. 进入项目根目录，加密证书。

```shell
travis encrypt-file XXX.jks --add
```

命令执行结果：
1. 在 Travis CI 控制台自动生成一对秘钥。
2. 基于秘钥通过 openssl 对文件进行加密，并在根目录生成 XXX.jks.enc 文件。
3. 在 .travis.yml 中自动生成 Travis CI 环境下解密文件的配置。

```yml
before_install:
  - openssl aes-256-cbc -K $encrypted_cd91ae131fae_key -iv $encrypted_cd91ae131fae_iv
    -in mrd@vdreamers.enc -out ~\/jks/mrd@vdreamers -d
```

#### 加密证书密码

在Travis CI控制台配置证书密码、证书别名、证书别名密码三个环境变量（KEYSTORE_PWD、KEYSTORE_ALIAS、KEYSTORE_ALIAS_PWD）。

#### 实现本地和Travis-CI构建release包互不干扰

基本思路，判断local.properties否存在，存在即为本地构建，不存在即为Travis-CI构建。
本地构建去local.properties中读取证书配置；Travis-CI构建通过System.getenv去读取环境变量的证书配置。

```gradle
apply plugin: 'com.android.application'

def keystorePWD = ''
def keystoreAlias = ''
def keystoreAliasPWD = ''
// local.properties file in the root director
def keyfile = project.rootProject.file('local.properties')

Properties properties = new Properties()
// local.properties exists
if (keyfile.exists()) {
    properties.load(keyfile.newDataInputStream())
} else {
    // Travis-CI
    keyfile = file("/jks/mrd@vdreamers")
    keystorePWD = System.getenv("KEYSTORE_PWD")
    keystoreAlias = System.getenv("KEYSTORE_ALIAS")
    keystoreAliasPWD = System.getenv("KEYSTORE_ALIAS_PWD")
}

// local.properties contains keystore.path
if (properties.containsKey("keystore.path")) {
    keyfile = file(properties.getProperty("keystore.path"))
    keystorePWD = properties.getProperty("keystore.password")
    keystoreAlias = properties.getProperty("keystore.alias")
    keystoreAliasPWD = properties.getProperty("keystore.alias_password")
} else {
    keyfile = file("no_exists_keystore.tmp")
}

android {
    signingConfigs {
        release {
            keyAlias keystoreAlias
            keyPassword keystoreAliasPWD
            storeFile keyfile
            storePassword keystorePWD
        }
    }
    buildTypes {
        debug {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.debug
        }
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            // 签名文件存在，则签名
            if (keyfile.exists()) {
                println("WITH -> buildTypes -> release: using jks key")
                signingConfig signingConfigs.release
            } else {
                println("WITH -> buildTypes -> release: using default key")
                signingConfig signingConfigs.debug
            }
        }
    }
}
```

本地构建需要在本地local.properties中配置好证书路径keystore.path、证书密码keystore.password、证书别名keystore.alias、证书别名密码keystore.alias_password；
分别对应着Travis CI控制台加密的证书秘钥对和环境变量证书密码KEYSTORE_PWD、证书别名KEYSTORE_ALIAS、证书别名密码KEYSTORE_ALIAS_PWD。