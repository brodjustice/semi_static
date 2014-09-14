Rails.application.routes.draw do

  mount SemiStatic::Engine => "/semi-static"
end
