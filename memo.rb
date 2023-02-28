# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi/escape'

JSON_PATH = './public/memos.json'

# GET methods
get '/memos' do
  @title = 'memos'
  @header = 'メモ一覧'

  write_in_json({}, JSON_PATH) unless File.exist?(JSON_PATH)

  @parsed_json = parse_json(JSON_PATH)

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

  parsed_json = parse_json(JSON_PATH)

  @memo_uuid = params[:uuid]

  memo_details = parsed_json[@memo_uuid]

  @memo_title = memo_details['title']
  @memo_content = memo_details['content']

  erb :detail
end

get '/memos/:uuid/edit' do
  @title = 'edit'
  @header = 'メモ編集'

  parsed_json = parse_json(JSON_PATH)

  @memo_uuid = params[:uuid]

  memo_details = parsed_json[@memo_uuid]

  @memo_title = memo_details['title']
  @memo_content = memo_details['content']

  erb :edit
end

# POST,PATCH,DELETE methods
post '/memos' do
  memo_uuid = SecureRandom.uuid.to_s

  # create new memo data
  create_or_update_memo(JSON_PATH, memo_uuid, params[:memo_title], params[:memo_content])

  redirect '/memos'
end

patch '/memos/:uuid' do
  # update memo
  create_or_update_memo(JSON_PATH, params[:uuid], params[:memo_title], params[:memo_content])

  redirect '/memos'
end

delete '/memos/:uuid' do
  parsed_json = parse_json(JSON_PATH)

  memo_uuid = params[:uuid]

  parsed_json.delete(memo_uuid)
  write_in_json(parsed_json, JSON_PATH)

  redirect '/memos'
end

# define original methods
def create_new_json(json_path)
  hash = {}

  write_in_json(hash, json_path)
end

def create_or_update_memo(json_path, memo_uuid, memo_title, memo_content)
  parsed_json = parse_json(json_path)
  parsed_json[memo_uuid] = { 'title' => memo_title, 'content' => memo_content }
  write_in_json(parsed_json, json_path)
end

def parse_json(json_path)
  File.open(json_path) do |file|
    JSON.parse(file.read)
  end
end

def write_in_json(hash, json_path)
  File.open(json_path, 'w') do |file|
    JSON.dump(hash, file)
  end
end
