concern :UserGeoSearch do
  class_methods do

    # Find users within a certain area.
    #
    #     User.within radius_in_km: 5, around: "Friedrichstr. 26, 91054 Erlangen, Germany"
    #
    def within(params)
      geo_locations = GeoLocation.near(params[:around], params[:radius_in_km])
      profile_fields = ProfileField.where value: geo_locations.map(&:address), type: "ProfileFields::Address"
      self.joins(:profile_fields).merge(profile_fields)
    end

  end
end