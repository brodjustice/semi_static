
SemiStatic::Role.create(:level => 1, :name => "admin")
SemiStatic::Role.create(:level => 3, :name => "user")

a = SemiStatic::User.new
a.name = 'business-landing'
a.surname = 'admin'

# This is the admin sign in email
a.email = 'admin@business-landing.com'

# This is the admin sign in password
a.password = 'admin-password-to-change'
a.password_confirmation = 'admin-password-to-change'

admin_role = SemiStatic::Role.find_by_name('admin')
a.roles << admin_role
a.save

SemiStatic::Tag.create(:name => 'Home', :menu => true, :position => 1, :locale => 'en', :predefined_class => 'Home', :colour => 'black', :icon_in_menu => false)
fcol = SemiStatic::Fcol.create(:name => "Footer Column #1", :position => 1, :content => "", :locale => "en")
SemiStatic::Fcol.create(:name => "Footer Column #2", :position => 2, :content => "", :locale => "en")
fcol.links.create(:name => "Business Landing Ltd", :url =>  "http://business-landing.com", :position => 0)
