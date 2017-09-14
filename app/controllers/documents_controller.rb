class DocumentsController < ApplicationController
  
  # Number of documents for each page
  FOR_PAGE = 8
  
  before_filter :initialize_document, :only => [:destroy, :update]
  before_filter :initialize_layout, :initialize_paginator, :only => :index
  
  # ### Description
  #
  # Main page of the section 'documents'. When it's called via ajax it's because of the application of filters, paginations, or after an operation that changed the number of items in the page.
  #
  # ### Mode
  #
  # Html + Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_layout
  # * DocumentsController#initialize_paginator
  #
  def index
    get_own_documents
    if @page > @pages_amount && @pages_amount != 0
      @page = @pages_amount
      get_own_documents
    end
    render_js_or_html_index
  end
  
  # ### Description
  #
  # Deletes definitively a document.
  #
  # ### Mode
  #
  # Json
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_document
  #
  def destroy
    if @ok
      if !@document.destroy_with_notifications
        @ok = false
        @error = I18n.t('activerecord.errors.models.document.problem_destroying')
      end
    else
      @error = I18n.t('activerecord.errors.models.document.problem_destroying')
    end
    render :json => {:ok => @ok, :msg => @error}
  end
  
  # ### Description
  #
  # Updates the general information of the document (title and description)
  #
  # ### Mode
  #
  # Ajax
  #
  # ### Specific filters
  #
  # * ApplicationController#initialize_document
  #
  def update
    if @ok
      @word = params[:word].blank? ? nil : params[:word]
      @document.title = params[:title]
      @document.description = params[:description]
      if !@document.save
        @errors = convert_document_error_messages @document.errors
      end
    end
  end
  
  # ### Description
  #
  # This action checks for errors without setting the attachment on the new document
  #
  # ### Mode
  #
  # Js
  #
  def create_fake
    record = Document.new
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.user_id = current_user.id
    record.valid?
    @errors = convert_document_error_messages record.errors
    @errors[:media] = t('documents.upload_form.attachment_too_large').downcase
  end
  
  # ### Description
  #
  # Action that calls the uploader and creates the new document
  #
  # ### Mode
  #
  # Html
  #
  def create
    record = Document.new :attachment => params[:media]
    record.title = params[:title_placeholder] != '0' ? '' : params[:title]
    record.description = params[:description_placeholder] != '0' ? '' : params[:description]
    record.user_id = current_user.id
    if !record.save
      if record.errors.added? :attachment, :too_large
        return render :file => Rails.root.join('public/413.html'), :layout => false, :status => 413
      end
      @errors = convert_document_error_messages record.errors
    end
    render :layout => false
  end
  
  private
  
  # Gets the documents using User#own_documents
  def get_own_documents
    current_user_own_documents = current_user.own_documents(@page, @for_page, @order, @word)
    @documents = current_user_own_documents[:records]
    @pages_amount = current_user_own_documents[:pages_amount]
  end
  
  # Initializes pagination parameters and filters
  def initialize_paginator
    @page = correct_integer?(params[:page]) ? params[:page].to_i : 1
    @for_page = FOR_PAGE
    @order = SearchOrders::DOCUMENTS_SET.include?(params[:order]) ? params[:order] : SearchOrders::CREATED_AT
    @word = params[:word].blank? ? nil : params[:word]
  end
  
end
