Rails.application.routes.draw do
  mount SemiStatic::Engine => "/semi_static"
end
