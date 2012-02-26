class PappsController < ApplicationController
  # GET /papps
  # GET /papps.json
  
  def index
    @papps = Papp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @papps }
    end
  end
  
  def scrape
    ag = Mechanize.new
    #ag.keep_alive = false  
    # Need to set this or you get OpenSSL errors:
    #ag.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = ag.get("http://portal.uspto.gov/external/portal/pair")
    # We need the recaptcha URL which has the token we want - on the Public Pair page, this is the table
    # class=epoTableBorder. The third tr has the recaptcha URL
    rc_url = page.parser.xpath("//table[@class='epoTableBorder']/tr[3]/td[1]/script[2]/@src")
    # If we download the code returned from visiting the recaptcha URL, then we can get the image token
    # The image token can then be sent into the google recaptch API to return the challege image
    rcpage = ag.get(rc_url)
    # The rcpage.body will have a string of javascript. From this, we want the string that follows from "content : "
    token = rcpage.body.partition("challenge : ")[2]
    token = token.partition(",")[0]
    # Now get rid of starting and ending quotes
    token = token[1..(token.length-2)]
    # Get the recaptcha image
    recaptcha_imageURL = ag.get("http://www.google.com/recaptcha/api/image?c=" + token)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @papps }
    end
  end
  
  def latestpubapps
    ag = Mechanize.new
    @apps = Array.new
    baseurl = "http://appft1.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-adv.html&r=0&f=S&l=50&d=PG01&"
    # figure out what today is, then what day the last thursday was.. wday for thursday = 4
    today = Date.today
    if today.wday < 5
      lthurs = today - (today.wday + 3)
    else
      lthurs = today - (today.wday - 4)
    end
    dsearch = lthurs.to_s
    @date = dsearch
    parts = dsearch.split('-')
    dateq = "Query=PD%2F" + parts[1] + "%2F" + parts[2] + "%2F" + parts[0]
    page = ag.get(baseurl + dateq)
    listing = page.parser.xpath("//table")
    trs = listing[0].xpath("//tr")
    trs.each_with_index do |tr, i|
      tds = tr.search('td')
      if i == 0
      else
        link = tds[1].search('a')
        link = "http://appft1.uspto.gov" + link.xpath("@href").to_s
        # tds[1] is the appno, tds[2] is the app title
        @apps[i-1] = [link, tds[1].text, tds[2].text]
      end
    end
    respond_to do |format|
      format.html # latestpubapps.html.erb
      #format.json { render json: @papps }
    end
  end

  # GET /papps/1
  # GET /papps/1.json
  def show
    @papp = Papp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @papp }
    end
  end

  # GET /papps/new
  # GET /papps/new.json
  def new
    @papp = Papp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @papp }
    end
  end

  # GET /papps/1/edit
  def edit
    @papp = Papp.find(params[:id])
  end

  # POST /papps
  # POST /papps.json
  def create
    @papp = Papp.new(params[:papp])

    respond_to do |format|
      if @papp.save
        format.html { redirect_to @papp, notice: 'Papp was successfully created.' }
        format.json { render json: @papp, status: :created, location: @papp }
      else
        format.html { render action: "new" }
        format.json { render json: @papp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /papps/1
  # PUT /papps/1.json
  def update
    @papp = Papp.find(params[:id])

    respond_to do |format|
      if @papp.update_attributes(params[:papp])
        format.html { redirect_to @papp, notice: 'Papp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @papp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /papps/1
  # DELETE /papps/1.json
  def destroy
    @papp = Papp.find(params[:id])
    @papp.destroy

    respond_to do |format|
      format.html { redirect_to papps_url }
      format.json { head :no_content }
    end
  end
end
