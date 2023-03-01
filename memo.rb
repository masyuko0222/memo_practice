# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'
require 'pg'

DB_URI = 'postgresql://memo_user:memo_pass@127.0.0.1:5432/memos'
CONN = PG::Connection.new(DB_URI)

# Helpers method
helpers do
  def select_all_memos
    CONN.exec_params('SELECT * FROM memos')
  end

  def select_details(memo_uuid)
    CONN.exec_params('SELECT memo_title, memo_content FROM memos WHERE memo_uuid = $1', [memo_uuid])
  end

  def create_memo(memo_uuid, memo_title, memo_content)
    CONN.exec_params('INSERT INTO memos VALUES($1, $2, $3)', [memo_uuid, memo_title, memo_content])
  end

  def update_memo(memo_uuid, memo_title, memo_content)
    CONN.exec_params('UPDATE memos SET memo_title = $2, memo_content = $3 WHERE memo_uuid = $1', [memo_uuid, memo_title, memo_content])
  end

  def delete_memo(memo_uuid)
    CONN.exec_params('DELETE FROM memos WHERE memo_uuid = $1', [memo_uuid])
  end
end

# GET methods
get '/memos' do
  @title = 'memos'
  @header = 'メモ一覧'

  @all_memos= select_all_memos

  erb :memos
end

get '/memos/new' do
  @title = 'new'
  @header = 'メモ追加'

  erb :new
end

get '/memos/:uuid' do
  @title = 'detail'
  @header = 'メモ内容'

  @memo_uuid = params[:uuid]
  @memo_details = select_details(@memo_uuid)

  erb :detail
end

get '/memos/:uuid/edit' do
  @title = 'edit'
  @header = 'メモ編集'

  @memo_uuid = params[:uuid]
  @memo_details = select_details(@memo_uuid)

  erb :edit
end

# POST,PATCH,DELETE methods
post '/memos' do
  memo_uuid = SecureRandom.uuid.to_s

  create_memo(memo_uuid, params[:memo_title], params[:memo_content])

  redirect '/memos'
end

patch '/memos/:uuid' do
  update_memo(params[:uuid], params[:memo_title], params[:memo_content])

  redirect '/memos'
end

delete '/memos/:uuid' do
  delete_memo(params[:uuid])

  redirect '/memos'
end
