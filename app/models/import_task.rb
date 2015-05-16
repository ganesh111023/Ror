class ImportTask < ActiveRecord::Base
  extend Enumerize

  TYPE_NEW     = 1
  TYPE_SYNC    = 2
  TYPE_UPDATE  = 3

  belongs_to :vendor

  enumerize :import_type, in: {new: TYPE_NEW, sync: TYPE_SYNC, update: TYPE_UPDATE}, scope: :having_type

end
