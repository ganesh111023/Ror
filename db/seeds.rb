# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([
                {first_name: 'John', last_name: 'Doe', email: 'admin@example.com',  password: '123qwe123', admin: 1},
                {first_name: 'Christopher ', last_name: 'Amott', email: 'user1@example.com',  password: '123qwe123'},
                {first_name: 'Peter ', last_name: 'Wagner', email: 'user2@example.com',  password: '123qwe123'},
                {first_name: 'Angela ', last_name: 'Gossow', email: 'user3@example.com',  password: '123qwe123'},
                {first_name: 'Daniel ', last_name: 'Day Lewis', email: 'user4@example.com',  password: '123qwe123'},
                {first_name: 'Rebecca ', last_name: 'Miller', email: 'user5@example.com',  password: '123qwe123'},
            ])

News.create([
                {
                    title: 'ХОРОШАЯ НОВОСТЬ! СНИЖЕНА ЦЕНА НА ВИБРОПЛИТЫ Tekpac!',
                    body: 'Because you have scoped the @reminder to the current user.  <br> That instance is added to the collection of reminders for that user, and so is also included in @reminders. This means that when you are rendering out the @reminders on the index page, It also tries to render out the unsaved @reminder which has not yet got an set. <br> A better solution would be to change you index action to. '
                },
                {
                    title: '<font color=blue>32LB530U по спеццене + бесплатная доставка в подарок! </font>',
                    body: 'Because you have scoped the @reminder to the <font color=red>current user</font>.  <br> That instance is added to the collection of reminders for that user, and so is also included in @reminders. This means that when you are rendering out the @reminders on the index page, It also tries to render out the unsaved @reminder which has not yet got an set. <br> A better solution would be to change you index action to. <br> <b>Because you have scoped the @reminder to the current user.</b>  <br> That instance is added to the collection of reminders for that user, and so is also included in @reminders. This means that when you are rendering out the @reminders on the index page, It also tries to render out the unsaved @reminder which has not yet got an set. <br> A better solution would be to change you index action to. '
                },
                {
                    title: 'ХОРОШАЯ НОВОСТЬ! СНИЖЕНА ЦЕНА НА ВИБРОПЛИТЫ Tekpac!',
                    body: 'Because you have scoped the @reminder to the current user.  <br> That instance is added to the collection of reminders for that user, and so is also included in @reminders. This means that when you are rendering out the @reminders on the index page, It also tries to render out the unsaved @reminder which has not yet got an set. <br> A better solution would be to change you index action to. '
                },
            ])

Country.create([{:code => 'en', :name => 'United States'},
                {:code => 'ru', :name => 'Россия'},
                {:code => 'fr', :name => 'Франция'},
                {:code => 'de', :name => 'Германия'},
              ])

root = Category.create!(:name => 'Movies, Music & Games ', :country_code => 'en')
    ch_1    = Category.create!(:name => 'CDs & Vinyl', :country_code => 'en')
    ch_1_2  = Category.create!(:name => 'Movies & TV', :country_code => 'en')
    ch_1.move_to_child_of(root)
    ch_1_2.move_to_child_of(root)
    root.reload

root2 = Category.create!(:name => 'Books & Audible ', :country_code => 'en')
    ch_2 = Category.create!(:name => 'Kindle Books', :country_code => 'en')
    ch_2.move_to_child_of(root2)
    root2.reload


root9 = Category.create!(:name => 'Климатическая техника', :country_code => 'ru')
ch9_1_1 = Category.create!(:name => 'Пушки тепловые', :country_code => 'ru')
ch9_1_1.move_to_child_of(root9)
root9.reload

Vendor.create([
                  {name: 'Watt прайс', markup_percent: 10},
                  {name: 'MPM', markup_percent: 12},
                  {name: 'Finland electronics',  markup_percent: 5},
              ])

category = Category.last
vendor   = Vendor.last

Product.create([
                   {name: 'RAGE Thirteen', model: 'Audio CD', vendor_price: 3, category: ch_1, vendor: vendor, country_ids: ['en']},
                   {name: 'RAGE Carved in Stone Enhanced', model: 'Audio CD', vendor_price: 2.05, category: ch_1, vendor: vendor, country_ids: ['en']},
               ])

Product.create([
                   {name: 'Пушка тепловая электрическая ELAND WARM CH-2P, 220 В, 2,0 кВт, 150 м2/ч',  vendor_price: 150, category: category, vendor: vendor, country_ids: ['ru']},
                   {name: 'Пушка тепловая электрическая Ecoterm EHR-02/1A, 2 кВт, 220В, 156 м3/ч, 20 м2, 3,5 кг',  vendor_price: 200.15, category: category, vendor: vendor, country_ids: ['ru']},
                   {name: 'Пушка тепловая электрическая Skiper ЛТ-3, 3кВт, 220V, 300 м.куб/час, 3,5 кг',  vendor_price: 47, category: category, status: Product::STATUS_EDIT, vendor: vendor, country_ids: ['ru']},
                   {name: 'Пушка тепловая электрическая Timberk TIH R3 3M, 3000 Вт, 35 кв.м',  vendor_price: 98.45, category: category, vendor: vendor, country_ids: ['ru']},
                   {name: 'Пушка тепловая электрическая ELAND WARM EH-3C, 220 В, 3,0 кВт, 355 м2/ч',  vendor_price: 13.13, category: category, status: Product::STATUS_DELETED, vendor: vendor, country_ids: ['ru']},
                   {name: 'Пушка тепловая электрическая Timberk TIH R3 5M, 5000 Вт, 50 м2, 420 м3/ч, 7 кг',  vendor_price: 18.02, category: category, vendor: vendor, country_ids: ['ru']},
               ])
