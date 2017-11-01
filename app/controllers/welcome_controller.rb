require 'json'
require 'nokogiri'

MIN_ID = 10000
MAX_ID = 99999
$usedIDs = Array.new
$link = ""
$herokuURL = "https://secret-msg.herokuapp.com"
$message = ""
$isBrowser = true

def is_json?(f)
	JSON.parse(f)
	true
rescue
	false
end

def is_xml?(f)
	return Nokogiri::XML(f).errors.empty?
end

def get_id
	isPresent = false
	until isPresent
		isPresent = false
		@temp = rand(MIN_ID..MAX_ID)
		isPresent = true unless $usedIDs.include?(@temp)
	end
	$usedIDs.push(@temp.to_s)
	return @temp.to_s
end

def del(id)
	$usedIDs.delete(id.to_s)
	Database.destroy(id)
end

def new(text, id)
	if text == ""
		$message = "ERR: PROVIDE SOME TEXT"
		$usedIDs.delete(id.to_s)
		$link = ""
		return 0
	end
	unless id == nil
		a = Database.create(:data => text, :id => id.to_i)
		b = a.save
		unless b
			$message = "ERR: COULD NOT SAVE MESSAGE"
			redirect_back(fallback_location: root_path)
			return 0;
		end
	end
end

def read(iden)
	unless $usedIDs.include?(iden.to_s)
		$message = "ERR: NO MESSAGE WITH THIS ID"
		if $isBrowser
			redirect_back(fallback_location: root_path)
		end
		return 0
	end
	a = Database.find(iden.to_i)
	$message = a.send(:data)
	$link = ""
	if $isBrowser 
		redirect_back(fallback_location: root_path)
	end
	del(iden.to_i)
end

class WelcomeController < ApplicationController
	protect_from_forgery unless: -> {request.format.json? }

	def index
	end

	def clear
		$link = ""
		$message = ""
	end

	def reset
		Database.delete_all
		$link = ""
		redirect_back(fallback_location: root_path)
	end
	
	def show
		id = params[:id]
		if id.to_i == -1
			reset
			return 0;
		end
		read(id)
	end

	def create
		clear
		text = params[:text]
		a = get_id
		$link = $herokuURL + "/messages/" + a
		new(text, a)
		redirect_back(fallback_location: root_path)
	end

	def api
		$isBrowser = false
		
		f = params[:file]

		if is_json?(f)
			f.open
			file = File.read(f.path)
			data = JSON.parse(file)

			if data.has_key?("message")
				a = get_id
				new(data["message"], a)
				render plain: a
				
			elsif data.has_key?("url")
				id = data["url"][-5..-1]
				read(id)
				render plain: $message
			end

		elsif is_xml?(f)


			data = File.open(f.path) { |f| Nokogiri::XML(f) }

			unless data.at_xpath('//message').blank?
				msg = data.at_xpath('//message').content
				a = get_id
				new(msg, a)
				render plain: a
			end

			unless data.at_xpath('//url').blank?
				id = data.at_xpath('//url').content[-5..-1]
				read(id)
				render plain: $message
			end
		end

		f.close
	end
end
