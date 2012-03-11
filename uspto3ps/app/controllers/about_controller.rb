#PatentBat - A web platform for facilitating the third party submissions of prior art under 37 CFR 1.290
#Copyright (C) 2012 Michelle M. Koeth
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as
#published by the Free Software Foundation, either version 3 of the
#License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
class AboutController < ApplicationController
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json 
    end
  end
end
