class Document < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditors

  include CurationConcern::WithMetaTags
  def special_meta_tag_fields
    %i(description language)
  end

  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: DocumentDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Text-based works other than articles: books, manuscripts, etc."

  def self.valid_types
    [ 'Book',
      'Book Chapter',
      'Document',
      'Report',
      'Pamphlet',
      'Brochure',
      'Manuscript',
      'Letter',
      'Newsletter',
      'Press Release',
      'White Paper' ]
  end

  attribute :alternate_title,
    datastream: :descMetadata, multiple: true

  attribute :bibliographic_citation,
    datastream: :descMetadata, multiple: false

  attribute :contributor,
    datastream: :descMetadata, multiple: true

  attribute :coverage_spatial,
    datastream: :descMetadata, multiple: true

  attribute :coverage_temporal,
    datastream: :descMetadata, multiple: true

  attribute :date_created,
    datastream: :descMetadata, multiple: false

  attribute :creator,
    datastream: :descMetadata, multiple: true
  
  attribute :date_modified, 
    datastream: :descMetadata, multiple: false

  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false

  attribute :description,
    datastream: :descMetadata, multiple: false

  attribute :identifier,
    datastream: :descMetadata, multiple: false,
    editable: false

  attribute :language,
    datastream: :descMetadata, multiple: true

  attribute :note,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :publisher,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :publisher_digital,
    default: "University of Cincinnati",
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :requires,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }

  attribute :source,
    datastream: :descMetadata, multiple: false

  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your article must have a title.' } }

  attribute :genre, datastream: :descMetadata,
    multiple: false,
    validates: { inclusion: { in: Document.valid_types,
                              allow_blank: true } }

  attribute :type,
    datastream: :descMetadata,
    multiple: false,
    default: "Text"

  attribute :files, multiple: true, form: {as: :file}
end
