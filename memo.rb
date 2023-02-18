require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

JSON_PATH = './public/memos.json'

# GET methods
get '/memos' do
  @title = 'memos'
  @header = 'メモ一覧'

  create_new_json(JSON_PATH) unless File.exist?(JSON_PATH)

  @parsed_json = open_parsed_json(JSON_PATH)

  erb :memos
end

get '/memos/new' do
  @title = 'new'
  @header = 'メモ追加'

  erb :new
end

get '/memos/:uuid' do
  parsed_json = open_parsed_json(JSON_PATH)
  @memo_uuid = params[:uuid]
  @memo_title = parsed_json[@memo_uuid]['title']
  @memo_content = parsed_json[@memo_uuid]['content']
  
  erb :detail
end

get '/memos/:uuid/edit' do
  parsed_json = open_parsed_json(JSON_PATH)
  @memo_uuid = params[:uuid]
  @memo_title = parsed_json[@memo_uuid]['title']
  @memo_content = parsed_json[@memo_uuid]['content']

  erb :edit
end

# POST,PATCH,DELETE methods
post '/memos' do
  memo_uuid = SecureRandom.uuid.to_s
  memo_title = params[:memo_title]
  memo_content = params[:memo_content]

  parsed_json = open_parsed_json(JSON_PATH)

  # add new memo data
  parsed_json[memo_uuid] = { 'title' => memo_title, 'content' => memo_content }
  overwrite_json(parsed_json, JSON_PATH)

  redirect '/memos'
end

patch '/memos/:uuid' do
  memo_uuid = params[:uuid]
  memo_title = params[:memo_title]
  memo_content = params[:memo_content]

  parsed_json = open_parsed_json(JSON_PATH)
  parsed_json[memo_uuid] = { 'title' => memo_title, 'content' => memo_content }
  overwrite_json(parsed_json, JSON_PATH)

  redirect '/memos'
end

delete '/memos/:uuid' do
  parsed_json = open_parsed_json(JSON_PATH)

  memo_uuid = params[:uuid]

  parsed_json.delete(memo_uuid)
  overwrite_json(parsed_json, JSON_PATH)

  redirect '/memos'
end

# define original methods
def create_new_json(json_path)
  File.new(json_path, 'w')

  hash = {}

  overwrite_json(hash, json_path)
end

def open_parsed_json(json_path)
  File.open(json_path) do |file|
    JSON.parse(file.read)
  end
end

def overwrite_json(hash, json_path)
  File.open(json_path, 'w') do |file|
    JSON.dump(hash, file)
  end
end
