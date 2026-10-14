# Role

あなたはRuby on Rails 8、PostgreSQL、Dockerに精通した
シニアフルスタックエンジニア兼技術教育者です。

RailsとDockerの初心者が学習できるように、
実務で利用される設計を意識しながら、
認証付きタスク管理アプリケーションを構築してください。

コードの実装だけでなく、
Docker、Rails、PostgreSQLの仕組みを日本語で説明してください。

# 最重要事項：既存Docker環境の保護

このMacでは、仕事用のDockerコンテナ、
Dockerイメージ、Volume、Networkが動作している可能性があります。

既存のDocker環境に影響を与える操作は禁止します。

以下のルールを厳守してください。

## 禁止操作

次のコマンドを実行しないでください。

- docker system prune
- docker container prune
- docker image prune
- docker volume prune
- docker network prune
- docker builder prune
- docker compose down -v
- docker rm -f $(docker ps -aq)
- docker stop $(docker ps -q)
- docker rmi
- docker volume rm
- docker network rm

また、以下も禁止します。

- 既存コンテナの停止・削除
- 既存Volumeの削除
- 既存Networkの削除
- 仕事用Dockerイメージの変更
- Docker Desktop全体の再起動
- Dockerのグローバル設定変更
- Docker contextの無断変更
- 既存のDocker Composeプロジェクトの操作
- 他プロジェクトへの影響が不明な操作

## Docker環境の分離

このプロジェクト専用のDocker Compose環境を作成してください。

Composeプロジェクト名は以下とします。

rails8-task-learning

compose.yamlには以下を設定してください。

name: rails8-task-learning

専用のVolumeとNetworkを使用してください。

既存のVolumeやNetworkをexternalとして参照しないでください。

container_nameは指定しないでください。

コンテナ名はDocker Composeに自動生成させてください。

ホスト側のポートは他のプロジェクトと衝突しないようにしてください。

Railsのポートは以下を候補とします。

13000:3000

ただし、ポート13000が使用中の場合は、
既存プロセスを停止せず、別の未使用ポートを提案してください。

PostgreSQLの5432ポートはホストに公開しないでください。

RailsコンテナからDocker内部ネットワーク経由で接続してください。

## Docker操作のルール

Docker操作は必ずこのプロジェクトのcompose.yamlを対象にしてください。

作業ディレクトリを確認してから実行してください。

他のDocker Composeプロジェクトには触れないでください。

Docker環境の確認は読み取り専用のコマンドを優先してください。

Docker Desktopが停止している場合は、
勝手に起動せず、ユーザーに状況を説明してください。

Dockerのbuild、up、down、execなどの実行前に、
操作対象のComposeプロジェクトを確認してください。

既存環境に影響する可能性がある場合は、
操作を実行せず、ユーザーに確認してください。

# 1. 技術構成

以下の技術を使用してください。

- Ruby 3.3
- Ruby on Rails 8
- PostgreSQL 17
- Docker Compose v2
- Devise
- Active Record
- Tailwind CSS
- Hotwire / Turbo
- ERB
- Minitest

Node.jsやJavaScriptのビルド環境は、
必要性を確認してから導入してください。

Rails標準の機能で実装できる場合は、
不要な依存関係を追加しないでください。

RailsはAPIモードではなく、
通常のMVCアプリケーションとして構築してください。

# 2. ディレクトリ構成

以下を基本構成としてください。

rails8-task-learning/
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   └── assets/
├── config/
├── db/
├── test/
├── docs/
│   ├── docker-guide.md
│   ├── rails-guide.md
│   ├── database-guide.md
│   └── commands.md
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── .gitignore
├── .env.example
├── Gemfile
├── Gemfile.lock
└── README.md

Railsの標準ディレクトリ構成を優先してください。

# 3. Dockerfile

開発環境向けのDockerfileを作成してください。

以下を考慮してください。

- Ruby 3.3の公式イメージ
- 必要最小限のOSパッケージ
- PostgreSQL接続用ライブラリ
- Bundler
- Gemfile.lockによる依存関係固定
- Dockerレイヤーキャッシュの活用
- 不要なファイルのコピー防止
- Railsの開発モード
- ソースコードのバインドマウント

Dockerfileの各命令について、
初心者向けに説明してください。

以下の命令を解説してください。

FROM
WORKDIR
RUN
COPY
ENV
EXPOSE
CMD

RUNとCMDの違いも説明してください。

# 4. .dockerignore

必ず.dockerignoreを作成してください。

以下を考慮してください。

.git
.github
.env
.env.*
!.env.example
node_modules
log/*
tmp/*
coverage
.bundle
vendor/bundle
.DS_Store
.idea
.vscode
docs

ただし、Railsの起動やビルドに必要なファイルまで
除外しないようにしてください。

.dockerignoreと.gitignoreの違いも説明してください。

特に以下を解説してください。

- Docker build contextとは何か
- なぜ.gitを除外するのか
- なぜ.envを除外するのか
- なぜnode_modulesを除外するのか
- .dockerignoreがDockerイメージに与える影響

# 5. Docker Compose

compose.yamlを作成してください。

サービスは以下の2つです。

web:
  Rails 8

db:
  PostgreSQL 17

以下を実装してください。

- プロジェクト専用Network
- プロジェクト専用Volume
- PostgreSQLのデータ永続化
- PostgreSQLのhealthcheck
- depends_onによる起動順序制御
- Railsのソースコードマウント
- Railsの開発用ポート公開
- 環境変数によるDB接続設定

PostgreSQLのパスワードはソースコードに
直接埋め込まず、開発用.envから読み込んでください。

.env.exampleを用意してください。

.envはGit管理対象から除外してください。

Railsコンテナの起動コマンドは、
開発環境に適したものにしてください。

# 6. Devise認証

Deviseを導入してください。

Userモデルを作成してください。

以下の機能を実装してください。

- ユーザー登録
- ログイン
- ログアウト
- パスワード再設定
- ログイン状態の確認

パスワード再設定メールについては、
開発環境で安全に動作確認できる方法を採用してください。

実際のメール送信サービスへの接続は不要です。

# 7. Taskモデル

UserとTaskは1対多の関係とします。

User has_many Tasks
Task belongs_to User

Taskには以下のカラムを作成してください。

id:
  bigint
  primary key

user_id:
  bigint
  foreign key
  not null

title:
  string
  not null

description:
  text
  nullable

status:
  integer
  default 0
  not null

priority:
  integer
  default 1
  not null

due_at:
  datetime
  nullable

completed_at:
  datetime
  nullable

created_at:
  datetime
  not null

updated_at:
  datetime
  not null

statusはenumを使用してください。

pending: 0
in_progress: 1
completed: 2

priorityもenumを使用してください。

low: 0
medium: 1
high: 2

titleにはバリデーションを設定してください。

必要なIndexと外部キー制約を追加してください。

# 8. PostgreSQLとタイムゾーン

日時管理は特に重要です。

PostgreSQLの日時型は
timestamp with time zone（timestamptz）
を使用してください。

Railsの設定は以下とします。

config.time_zone = "Tokyo"

config.active_record.default_timezone = :utc

PostgreSQL側のセッションタイムゾーンはUTCにしてください。

Railsのdatetime型がPostgreSQLの
timestamptzとして作成されるように設定してください。

UserモデルのDevise関連日時カラムも含め、
日時型の整合性を確認してください。

以下の変換を保証してください。

日本時間:
2026-10-14 18:00

UTC:
2026-10-14 09:00

DB保存時:
UTC基準

画面表示時:
Asia/Tokyo

HTMLのdatetime-local入力についても、
日本時間として正しく解釈してください。

9時間ずれる不具合が発生しないようにしてください。

既存マイグレーションがある場合は、
安全性を確認してから変更してください。

既存データの削除は禁止です。

# 9. Task CRUD

以下の機能を実装してください。

- 一覧表示
- 詳細表示
- 新規作成
- 編集
- 更新
- 削除

RESTfulなルーティングを使用してください。

TasksControllerを作成してください。

認証済みユーザーだけがアクセスできるようにしてください。

Taskの取得には以下を使用してください。

current_user.tasks

他のユーザーが作成したTaskを
閲覧・編集・削除できないようにしてください。

Strong Parametersを使用してください。

user_idを更新可能なパラメータに含めないでください。

# 10. Tailwind CSS

tailwindcss-railsを使用してください。

Tailwind CSS v4に対応した構成にしてください。

以下の画面を実装してください。

- ログイン
- ユーザー登録
- Task一覧
- Task詳細
- Task作成
- Task編集

シンプルで見やすいUIにしてください。

PCとスマートフォンに対応してください。

UIには以下を表示してください。

- タスク名
- 説明
- ステータス
- 優先度
- 期限
- 作成日時
- 編集ボタン
- 削除ボタン

日本語UIを基本としてください。

# 11. テスト

Minitestを使用してください。

以下のテストを実装してください。

- Userの登録
- Userのログイン
- Taskの作成
- Taskの一覧取得
- Taskの更新
- Taskの削除
- Taskのバリデーション
- 未ログイン時のアクセス制限
- 他ユーザーのTaskへのアクセス制限
- UTCとJSTの変換
- timestamptzのカラム型確認

テスト実行コマンドもREADMEに記載してください。

# 12. 初心者向けドキュメント

docsディレクトリに日本語の解説を作成してください。

特にDockerとRailsの基本概念を
初心者が理解できるように説明してください。

## docs/docker-guide.md

以下を解説してください。

- Dockerとは何か
- Docker Imageとは何か
- Docker Containerとは何か
- Dockerfileとは何か
- Docker Composeとは何か
- Volumeとは何か
- Networkとは何か
- Bind Mountとは何か
- Docker buildとは何か
- Docker runとは何か
- docker compose upとは何か
- docker compose downとは何か
- docker compose execとは何か
- docker compose runとは何か
- docker compose logsとは何か

また、以下の違いも説明してください。

docker run
docker exec
docker compose run
docker compose exec

## docs/commands.md

Dockerコマンドのオプションを詳しく説明してください。

特に以下を解説してください。

exec
-it
-i
-t
-d
--rm
--build
--no-cache
-f
-p
-v

例えば以下のコマンドについて、
1つずつ意味を説明してください。

docker exec -it container_name bash

docker compose exec web bash

docker compose run --rm web bash

docker compose up -d

docker compose up -d --build

docker compose build --no-cache web

docker compose logs -f web

docker compose ps

docker compose down

各コマンドについて以下を説明してください。

1. コマンドの意味
2. オプションの意味
3. どのような場面で使用するか
4. 実行すると何が起きるか
5. 既存Docker環境への影響
6. 初心者が注意するポイント

特にexecとrunの違いを詳しく説明してください。

## docs/rails-guide.md

以下を解説してください。

- Railsとは何か
- MVCとは何か
- Modelとは何か
- Viewとは何か
- Controllerとは何か
- Routingとは何か
- Active Recordとは何か
- Migrationとは何か
- Validationとは何か
- Associationとは何か
- Deviseとは何か
- Strong Parametersとは何か

また、以下のコマンドを解説してください。

bin/rails server
bin/rails console
bin/rails generate model
bin/rails generate controller
bin/rails db:create
bin/rails db:migrate
bin/rails db:rollback
bin/rails routes
bin/rails test

## docs/database-guide.md

以下を解説してください。

- PostgreSQLとは何か
- RDBMSとは何か
- Primary Keyとは何か
- Foreign Keyとは何か
- Indexとは何か
- NOT NULLとは何か
- timestampとは何か
- timestamptzとは何か
- UTCとは何か
- JSTとは何か
- RailsとPostgreSQLのタイムゾーンの関係

Taskテーブルを使ってSQLの例も示してください。

# 13. README.md

READMEには以下を記載してください。

1. プロジェクト概要
2. 技術構成
3. 必要なソフトウェア
4. 初回セットアップ
5. Dockerイメージのビルド
6. コンテナの起動
7. DBの作成
8. マイグレーション
9. Railsへのアクセス
10. ユーザー登録
11. TaskのCRUD操作
12. Railsコンソールの起動
13. PostgreSQLへの接続
14. テストの実行
15. ログの確認
16. コンテナの停止
17. よくあるエラーと対処方法

すべてのDockerコマンドは、
このプロジェクトだけを対象にする形で記載してください。

# 14. 実装手順

以下の順番で進めてください。

Phase 1:
既存ファイルとDocker環境の調査

Phase 2:
Dockerfile、compose.yaml、.dockerignoreの作成

Phase 3:
Rails 8の初期構築

Phase 4:
PostgreSQL接続設定

Phase 5:
タイムゾーン設定

Phase 6:
Devise導入

Phase 7:
UserとTaskモデル作成

Phase 8:
CRUD実装

Phase 9:
Tailwind CSSによるUI実装

Phase 10:
テスト

Phase 11:
初心者向けドキュメント作成

Phase 12:
動作確認

# 15. 実行時の注意

実装前に現在のプロジェクト構成を調査してください。

既存ファイルを勝手に削除しないでください。

既存Docker環境を変更しないでください。

Docker Composeのプロジェクト名を確認してください。

既存Volumeを削除しないでください。

ビルド時に不要なファイルが含まれていないか
.dockerignoreを確認してください。

Dockerイメージのビルド前に、
対象のDockerfileとCompose設定を確認してください。

Docker Desktopの設定は変更しないでください。

Docker Compose以外のコンテナを操作しないでください。

実装完了後、以下を報告してください。

- 作成したファイル
- 使用したDockerイメージ
- 起動したコンテナ
- 作成したVolume
- 作成したNetwork
- 実行したマイグレーション
- テスト結果
- 動作確認結果
- 未解決の問題

最優先事項は、
仕事用Docker環境に影響を与えないことです。