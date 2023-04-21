# frozen_string_literal: true

require 'csv'

class MaintainPlanSFunders
  ##
  # Responsible for initial loading & maintenance of PlanSFunder model data.
  def self.call(csv_path: "lib/data/plan_s_funders.csv")
    @doi_in_csv = []
    @funders_to_reindex = []
    csv_data = File.read(csv_path)
    CSV.parse(csv_data, headers: true) do |row|
      convert_to_funder(row: row)
    end
    # This is preparation for using API calls... funders may be removed
    # rather than just deactivated as we are doing in CSV
    handle_removed_funders
    # @TODO: Process list of funder DOIs to reindex in the rake task (this is not happening yet).
    @funders_to_reindex
  end

  def self.convert_to_funder(row:)
    record_data = row.to_hash.symbolize_keys
    maintain_record(data: record_data)
  end
  private_class_method :convert_to_funder

  def self.handle_removed_funders
    PlanSFunder.where.not(funder_doi: @doi_in_csv).each do |funder|
      funder.update(funder_status: 'inactive')
      need_to_reindex(funder: funder)
    end
  end
  private_class_method :handle_removed_funders

  def self.maintain_record(data:)
    @doi_in_csv << data[:funder_doi]

    # Update record based on this row
    funder = find_or_initialize_funder(data: data)

    if funder.new_record? ||
       funder.funder_status != data[:funder_status] ||
       funder.funder_name != data[:funder_name]

      funder.funder_status = data[:funder_status]
      funder.funder_name = data[:funder_name]
      funder.save
      need_to_reindex(funder: funder)
    end

    true
  end
  private_class_method :maintain_record

  def self.find_or_initialize_funder(data:)
    PlanSFunder.find_or_initialize_by(funder_doi: data[:funder_doi]) do |funder|
      funder.funder_name = data[:funder_name]
      funder.funder_status = data[:funder_status]
    end
  end
  private_class_method :find_or_initialize_funder

  def self.need_to_reindex(funder:)
    @funders_to_reindex << funder.funder_doi
  end
  private_class_method :need_to_reindex
end
