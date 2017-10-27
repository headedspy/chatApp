MIN_ID = 1
MAX_ID = 2
$usedIDs = Array.new

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
	a = Database.create( :number => id.to_s, :data => text, :id => id.to_i)
	b = a.save
	unless b
		render plain: "Gre6ka maina"
		return 0;
	end
	render plain: id
end

def read(id)
	unless $usedIDs.include?(id.to_s)
		render plain: ">>>MAHAISAWE<<<"
		return 0;
	end
	a = Database.find(id.to_i)
	render plain: a.send(:data)
	del(id)
end

class WelcomeController < ApplicationController
	def index
	end

	def reset
		Database.delete_all
	end
	
	def show
		id = params[:id]
		read(id)
	end

	def create
		text = params[:text]
		a = get_id
		new(text,a)
	end
end
