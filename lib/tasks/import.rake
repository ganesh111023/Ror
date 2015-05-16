namespace :import do

  task :reccuring => :environment do

    rates = Rails.cache.fetch "money:eu_central_bank_rates", expires_in: 24.hours do
      Money.default_bank.save_rates_to_s
    end
    Money.default_bank.update_rates_from_s rates

    tasks = ImportTask.all
    tasks.each do |t|
      puts ''
      puts "Started import for #{t.vendor.name}"
      puts "File: #{t.file_url}"
      puts ''
      begin
        opts = {:input_currency => t.currency, :vendor_id => t.vendor_id, :url => t.file_url, :extension => t.file_extension, :import_type => t.import_type.value, :locale => t.country_code}
        r = Product.import(nil, opts)

        t.job_count += 1
        t.updated_at = Time.now.to_s(:db)
        t.save

        puts I18n.t('admin.products.import.notice', np: r[:new_products], up: r[:updated_products], nc: r[:new_categories])
      rescue RuntimeError => e
        puts e.message
      end
    end
  end

end