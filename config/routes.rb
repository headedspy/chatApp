Rails.application.routes.draw do
  resources :databases
 	get 'welcome/index'
	get 'messages/:id' => 'welcome#show'

	root 'welcome#index'
	post 'welcome/index' => 'welcome#create'
end

