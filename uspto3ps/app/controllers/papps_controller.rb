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
  
  def getcaptcha
    ag = Mechanize.new
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
    session['tok'] = token
    # Get the recaptcha imageURL
    @recaptcha_imageURL = "http://www.google.com/recaptcha/api/image?c=" + token
    # You cant serialize a Mechanize object, (coz of live TCP connection) but you can serialize the cookies
    ag.cookie_jar.save_as('cookies.yml')
    getjss= page.body.partition('function getDossier() {')
    # We also need to save specifically the save form's action which is hidden up in the javascript
    sfactionin = page.body.index("document.save.action =  '/external/portal")
    session['sfactiontok'] = page.body[(sfactionin+25)..(sfactionin+331)]
    #puts "form action: " + session['sfactiontok']
    session['getdoscodes'] = getjss[2].partition('</script>')[0]
    jsreplace = page.body.partition('<script type="text/javascript" src="http://api.recaptcha.net/challenge?k=')[2]
    session['jsrep'] = jsreplace.partition('</script>')[0]
    #aFile = File.new("page.html", "w")
    #aFile.write(page.body)
    #aFile.close
    # USe the current_page function with the mechanize agent once it is reestablished by reloading the serialized cookie jar
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @papps }
    end
  end
  
  def postcaptchascrape
    appno = params[:apppubno]
    ag = Mechanize.new
    ag.cookie_jar.load('cookies.yml')
    page = ag.get("http://portal.uspto.gov/external/portal/pair")
    getjss= page.body.partition('function getDossier() {')
    doscodes = getjss[2].partition('</script>')[0]
    # replace the new getDossier function with the previous one for which we have the captcha info
    page.body.sub(doscodes,session['getdoscodes'])
    # The javascript that deals with the captcha must be copied out and replaced in the new page. Then we also might need all the
    # hidden vars as well. This is the getDossier() function, and
    # <script type="text/javascript" src="http://api.recaptcha.net/challenge?k=..."></script>
    jsreplace = page.body.partition('<script type="text/javascript" src="http://api.recaptcha.net/challenge?k=')[2]
    page.body.sub(jsreplace.partition('</script>')[0], session['jsrep'])
    form = page.forms.first
    form['recaptcha_response_field'] = params[:recaptcharesponse]
    form['recaptcha_challenge_field'] = session['tok']
    resp = form.submit
    #aFile = File.new("resp.html", "w")
    #aFile.write(resp.body)
    #aFile.close
    # At this point, we are recaptcha'd thru into PAIR. Next up is submitting a patent app no to get the filewrapper
    # Originally I tried to submit the form using the patentpub no, but I was unable to successfully get the form to
    # search against publication number, so I switched to searching against the default patent app number
    form1 = resp.forms.first
    #form1.fields.each { |f| puts f.name }
    #form1.radiobutton_with(:value => "appId").uncheck
    #form1.radiobutton_with(:value => "pgPubsNo").check
    #form1.radiobutton_with(:value => "pgPubsNo").click
    #puts "Appno checked? is: " + form1.radiobutton_with(:value => "appId").checked?.to_s + " PubNo checked? is: " + form1.radiobutton_with(:value => "pgPubsNo").checked?.to_s
    # id is number_id, name is dosnum
    form1['dosnum'] = appno
    # Next submit the form by clicking the submit button
    form1['selecteddosnum'] = appno
    form1['dosnumber'] = appno
    form1['isSubmitted'] = "isSubmitted"
    form1['submitButtonClicked'] = "submitButtonClicked"
    form1['selectedApplication'] = 0 #document.save.AppSearchType.selectedIndex
    @actionf = session['sfactiontok']
    form1.action = session['sfactiontok']
  	#if('/external/portal/!ut/p/c5/04_SB8K8xLLM9MSSzPy8xBz9CP0os3hff1NDc1NLYwN3SzcDA08PwyD_YF8zINcYKB-JW97AiCLdBgR0h4Nci992vPIGEHkDHMDRQN_PIz83Vb8gNzTCIDMgHQCGKKj-/dl3/d3/L0lDU0lKSWdrbUNTUS9JUFJBQUlpQ2dBek15cXpHWUEhIS80QkVqOG8wRmxHaXQtYlhwQUh0Qi83X01PNTE3NTkzMEc5RjAwSUgxUk9TTTYzMDI2L3YyTVdVMzkyNjAwMDgvc2EuZ2V0Qmli/' == ''){
  	#document.save.action =  'null';
    
  	#  	document.save.action =  '/external/portal/!ut/p/c5/04_SB8K8xLLM9MSSzPy8xBz9CP0os3hff1NDc1NLYwN3SzcDA08PwyD_YF8zINcYKB-JW97AiCLdBgR0h4Nci992vPIGEHkDHMDRQN_PIz83Vb8gNzTCIDMgHQCGKKj-/dl3/d3/L0lDU0lKSWdrbUNTUS9JUFJBQUlpQ2dBek15cXpHWUEhIS80QkVqOG8wRmxHaXQtYlhwQUh0Qi83X01PNTE3NTkzMEc5RjAwSUgxUk9TTTYzMDI2L3YyTVdVMzkyNjAwMDgvc2EuZ2V0Qmli/'
  	
    form1['testHidden'] = 'appId'
    form1['public_selectedSearchOption'] = 'pair_applicationSearchoption'
    form1['is_pair_new_search'] = 'appId'
    form1['AppSearchType'] = 'appId'
    resp2 = form1.click_button
    aFile = File.new("resp2.html", "w")
    aFile.write(resp2.body)
    aFile.close
    #form1.button_with(:value => "SEARCH").click

    
  end
  
  def latestpubapps
    # see if there are already the latest published apps in the database
    today = Date.today
    # figure out what today is, then what day the last thursday was.. wday for thursday = 4
    if today.wday < 5
      lthurs = today - (today.wday + 3)
    else
      lthurs = today - (today.wday - 4)
    end
    @papp = Papp.find(:all, :conditions => { :pubdate => lthurs})
    # now @papp will have all published apps that are in the database from the last publishing date (thurs)
    ag = Mechanize.new
    @apps = Array.new
    baseurl = "http://appft1.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-adv.html&r=0&f=S&l=50&d=PG01&"
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
      @apps.each do |app|
        # See if there is already a Papp in the database for the one just found:
        dbpapp = Papp.find(:first, :conditions => "pubno = '#{app[1]}'")
        if dbpapp
          #then there is one in the db already - we will check if all fields are there
          Papp.update(dbpapp.id, {:pubno => app[1], :published => true, :pubdate => lthurs, :pubrequest => true, :title => app[2], :linktoapp => app[0]})
        else
          # there is no papp in the database - need to add one
          p = Papp.new(:pubno => app[1], :published => true, :pubdate => lthurs, :pubrequest => true, :title => app[2], :linktoapp => app[0])
          p.save
        end
      end
      @papps = Papp.all
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
