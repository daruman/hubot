IntegrateSlack
================================================================================


How to Integration
--------------------------------------------------------------------------------

きほんSlackとBacklog側で設定して、hubotのconfigにIntegrationしたいSlackとBacklogの設定を追加するだけ。  
最後にそのconfig呼んで起動させる。


1. SlackでHubot Integration登録しTokenを払い出す  
メニューの `Configure Integrations`から

2. サーバでIntegration対象のconfigを追加
```
sudo su # 基本rootで作業したほうがトラブらない
cd /usr/src/hubot
ls -l config # 使用済みポート番号をファイル名から確認
cp config/example config/{config_name}
vim {config_name} # 編集、内容はコメント参照
sh hubot-launch.sh {config_name}
```
`config_name`は{BACKLOG_PROJECTNAME}-{PORT}な感じで、使用ポート番号がわかるようにしてあげるとやさしい。  
例: Backlogのプロジェクトコードが(PROJECT_HOGE)で、既にport8080-8082が使用済みだった場合、`PROJECT_HOGE-8083`  
また、作成したconfig内に記述するWEBHOOK_KEYWORDは任意。

3. backlogにwebhook設定追加  
Webhook名・説明は適当に、通知するイベントは適時必要なものをチェック。  
WebHook URLには以下のように入力。
```
http://{hubot_hosting_server}:{use_port}/{webhook_keyword}/{channel_name}
```
  - `hubot_hosting_server`: hubot動かすEC2インスタンス
  - `use_port`: 使用するport番号
  - `webhook_keyword`: hubotに追加したconfigに記載した文字列
  - `channel_name`: webhookが叩かれた際に投稿先となるSlackのチャンネル名

4. launchする
```
sh hubot-launch.sh {config_name}
```


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
以下付録、1から作りたい人用メモ
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


hubotの作り方
--------------------------------------------------------------------------------

1. node.jsを入れておく

2. 必要なnpmパッケージのインストール
```
npm update -g npm # npm アップデート
npm install -g yo generator-hubot hubot coffee-script
```

3. hubot雛形作成
```
mkdir hubot
cd bot
yo hubot
# > Owner: <Enter>
# > Bot name: IntegrateSlack
# > Description: Integrate Slack
# > adapter: slack
```
対話型なので必要な情報を入れていく。  
adapterさえ"slack"と入力する点のみ必須。

4. backlog用script作成
```
touch script/backlog.coffee
```
中身はソース参照。

5. configファイル作成
```
mkdir config
vim config/example
```
このexampleを雛形に、追加する設定毎にファイルを増やす事になる。

6. launch.sh作成
botにパラメータを渡しつつデーモン化するための起動用shell script
```
vim launch-hubot.sh
```
中身はソース参照。



サーバ設定でやった事
--------------------------------------------------------------------------------


### 1. backlogのwebhookからアクセス可能にしておく
AWSのセキュリティグループのインバウンドに以下を追加
(IPはbacklogのもの)

| タイプ | プロトコル | ポート範囲 | 送信元 |
| :-- | :-- | :-- | :-- |
| カスタムTCP | TCP | 8080-9999 | 54.238.59.48/32 |

  httpd用のportが開いているとアクセス可能だが、hubotで使用するportとぶつかるため別にあけておく



### 2. 必要なのをインストール

#### nodejs/npm install
<pre>
sudo su

# nodebrew install
cd /usr/local/src
wget git.io/nodebrew
chmod +x nodebrew

# nodebrew setup
export NODEBREW_ROOT=/opt/nodebrew
./nodebrew setup
ln -s /opt/nodebrew/completions/bash/nodebrew-completion /etc/bash_completion.d/
vim /etc/profile.d/nodebrew.sh # 以下行を記述
# > export PATH=/opt/nodebrew/current/bin:$PATH
# > export NODEBREW_ROOT=/opt/nodebrew
source /etc/profile

# node install
./nodebrew install-binary v4.0.0
./nodebrew use v4.0.0

# check
node -v && npm -v
</pre>

#### redis install & chkconfig on
```
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum --enablerepo=remi -y install redis
/etc/init.d/redis start
chkconfig redis on
```

#### git install
```
yum -y install git
```

#### npm package install
```
npm install -g hubot coffee-script forever
```

### 3. サーバに作成したhubotを展開
```
cd /usr/local/src/
git clone {https git Repository}
cd {Repository directory}
cp config/example config/{BACKLOG_PROJECTNAME-PORT}
vim config/{BACKLOG_PROJECTNAME-PORT}
```
ポート番号は他のconfigと被らないように、インバウンドで設定した範囲内のものを使用

### 4. 起動
```
sh hubot-launch.sh {BACKLOG_PROJECTNAME-PORT} # パラメータとしてconfigファイル名を渡す
```


スクリプトの追加の仕方
--------------------------------------------------------------------------------

- 単品ならscriptディレクトリに追加
- defaultで持っているものを有効化するならhubot-scripts.jsonに追記
- 配布されているなら`$ npm install --save hoge/fuga`とか

最後に`$ forever restartall`でデーモン化したhubot達を再起動  
(将来的にforeverでhubot以外のnode.js scriptを永続化する場合、ちゃんと一個づつ再起動しよう！)



