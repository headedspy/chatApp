
require 'nokogiri'

MIN_ID = 10000
MAX_ID = 99999
$usedIDs = Array.new
$link = ""
$herokuURL = "https://secret-msg.herokuapp.com"
$message = ""

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
		redirect_back(fallback_location: root_path)
		return 0
	end
	a = Database.find(iden.to_i)
	$message = a.send(:data)
	$link = ""
	redirect_back(fallback_location: root_path)
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

	def notesapi
		type = request.headers["Content-Type"]
		uid = get_id
		$link = $herokuURL + "/messages/" + uid
		res = {"url" => $link}
		if type == "application/json"
			text = params[:message]
			render json: res
			
		elsif type == "text/xml"
			text = Nokogiri::XML.fragment(request.body.read).content
			render xml: res
		end	
		new(text, uid)
	end
end
