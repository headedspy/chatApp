MIN_ID = 1
MAX_ID = 10000
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
	unless id != nil
		a = Database.create( :number => id.to_s, :data => text, :id => id.to_i)
		b = a.save
		unless b
			$message = "ERR: COULD NOT SAVE MESSAGE"
			redirect_back(fallback_location: root_path)
			return 0;
		end
	end
end

def read(id)
	unless $usedIDs.include?(id.to_s)
		$message = "ERR: NO MESSAGE WITH THIS ID"
		redirect_back(fallback_location: root_path)
		return 0
	end
	a = Database.find(id.to_i)
	$message = a.send(:data)
	$link = ""
	redirect_back(fallback_location: root_path)
	del(id)
end

class WelcomeController < ApplicationController
	def index
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
		a = get_id
		text = params[:text]
		$link = $herokuURL + "/messages/" + a
		new(text,a)
		redirect_back(fallback_location: root_path)
	end
end
