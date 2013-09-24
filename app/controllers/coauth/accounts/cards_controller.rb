module Accounts
  class CardsController < ApplicationController
    require 'scrypt'

      respond_to :json
        
      def index
        if current_user
          response =  Card.by_user(current_user.id)
        else
          response = nil
        end
         respond_with response
      end

      def create
        @card = Card.create!(params[:card].merge!(:lastfour => params[:card][:cardno][12, 4], :user_id => session[:user_id], :carddetails => params[:card][:cardno] + ' ' + params[:card][:expirymonth] + ' ' + params[:card][:expiryyear] + ' ' + params[:card][:cvc]))
        respond_with :accounts, @card
      end

      def pay 
        cardinput = params[:card][:cardno] + ' ' + params[:card][:expirymonth] + ' ' + params[:card][:expiryyear] + ' ' + params[:card][:cvc]
        salt =  '800$8$59$' + Base64.encode64(Digest::SHA1.hexdigest(cardinput))[0..-4]
        card = Card.find_by_id(SCrypt::Engine.hash_secret(cardinput, salt))

        if card
          @user = User.find_by_id(card.user_id)
          # Log user in
        else
          # Create a user for the card
          @user = User.create!({:name => params[:card][:name], :email => params[:card][:email], :guest => true})
          # Create the card
          @card = Card.create!(params[:card].merge!(:lastfour => params[:card][:cardno][12, 4], :user_id => @user.id, :carddetails => params[:card][:cardno] + ' ' + params[:card][:expirymonth] + ' ' + params[:card][:expiryyear] + ' ' + params[:card][:cvc]))
        end
        self.current_user = @user

        path = '/oauth/authorize?response_type=' + session[:oauthparams][:response_type]
        path += "&redirect_uri=" + session[:oauthparams][:redirect_uri]
        path += "&client_id=" + session[:oauthparams][:client_id]
        render json: {:path => path}, :layout => false
      
      end
  end
end

