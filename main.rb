# frozen_string_literal: true

puts "This is process #{Process.pid}"

require 'sinatra'
require 'rubygems'
require 'sinatra/reloader'
require 'bundler/setup'
require 'json'
enable :method_override

# json setting & memo.json memo content

def json_path
  'json/memo.json'
end

$jsondata = open(json_path) do |i|
  JSON.load(i)
end

# get memos array from json data & memo content
def memos
  jsondata['memos']
end

# define memo id
def memo(m_id)
  r_memo = ''
  memos.each do |memo|
    if memo['id'].to_s == m_id.to_s
      r_memo = memo
      puts m_id
    end
  end
  r_memo
end

# rewrite json
def overwrite
  copied_data = jsondata
  File.open(json_path, 'w') do |file|
    JSON.dump(copied_data, file)
  end
end

# show each page
get '/' do # index
  @heading = 'メモアプリの'
  @subtitle = '魔力'
  @memos = memos
  erb :index
end

# view memo contents
get '/memo/:id' do
  @memo = memo(params[:id])
  erb :details
end

# new
get '/new' do
  @heading = 'メモアプリ'
  erb :new
end

# store data
post '/new' do
  last_id = 0
  memos.each do |count|
    last_id = count['id'].to_i + 1 if last_id <= count['id'].to_i # adds +1 when count < last_id
  end

  # create new data
  new_json_data = { 'id' => last_id.to_s, 'title' => params[:title], 'content' => params[:content] }
  $jsondata['memos'].push(new_json_data)

  File.open(json_path, 'w') do |file|
    JSON.dump($jsondata, file)
  end
  # overwrite
  redirect '/'
  erb :index
end

# delete memo
delete '/memo/delete/:id' do
  id = 0
  memos.each do |d|
    memos.delete_at(id) if d['id'].to_s == params[:id].to_s
    id += 1
  end
  overwrite
  redirect '/'
  erb :index
end

# edit memo contents
get '/memo/edit/:id' do
  @memo = memo(params[:id])
  erb :edit
end

patch '/memo/do-edit/:id' do
  new_json_data = { 'id' => params[:id].to_s, 'title' => params[:title], 'content' => params[:content] }

  id = 0
  memos.each do |edit|
    if edit['id'].to_s == params[:id].to_s
      memos[id]['title'] = new_json_data['title']
      memos[id]['content'] = new_json_data['content']
    end
    id += 1
  end

  overwrite

  redirect '/'
  erb :index
end
