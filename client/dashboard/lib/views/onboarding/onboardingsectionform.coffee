kd = require 'kd'
KDFormViewWithFields = kd.FormViewWithFields
KDSelectBox = kd.SelectBox
remote = require('app/remote').getInstance()
globals = require 'globals'
KodingSwitch = require 'app/commonviews/kodingswitch'


module.exports = class OnboardingSectionForm extends KDFormViewWithFields

  constructor: (options = {}, data) ->

    apps = []
    apps.push { title: app, value: app }  for app of globals.config.apps

    options.cssClass      = "section-form"
    @jCustomPartial       = data
    formData              = data?.partial or {}
    options.fields        =
      name                :
        placeholder       : "Name of your set"
        name              : "name"
        cssClass          : "thin"
        label             : "Name"
        defaultValue      : data?.name or ""
      app                 :
        name              : "app"
        label             : "App"
        cssClass          : "app"
        type              : "hidden"
        nextElement       :
          app             :
            itemClass     : KDSelectBox
            cssClass      : "apps"
            defaultValue  : formData?.app
            selectOptions : apps

    options.buttons       =
      Save                :
        title             : "SAVE CHANGES"
        style             : "solid green medium fr"
        callback          : @bound "save"
      Cancel              :
        title             : "CANCEL"
        style             : "solid medium fr cancel"
        callback          : @bound "cancel"

    super options, data


  save: ->

    data              =
      partialType     : "ONBOARDING"
      partial         :
        visibility    : no
        overlay       : yes
        app           : @inputs.app.getValue()
        items         : @jCustomPartial?.partial.items   or []
      name            : @inputs.name.getValue()          or ""
      viewInstance    : @jCustomPartial?.viewInstance    or ""
      isActive        : @jCustomPartial?.isActive        or no
      isPreview       : @jCustomPartial?.isPreview       or no
      previewInstance : @jCustomPartial?.previewInstance or no

    if @jCustomPartial
      @jCustomPartial.update data, (err, section) =>
        return kd.warn err  if err
        @destroy()
        @getDelegate().emit "SectionSaved"
    else
      remote.api.JCustomPartials.create data, (err, section) =>
        return kd.warn err  if err
        @destroy()
        @getDelegate().emit "SectionSaved"


  cancel: ->

    @getDelegate().emit "SectionCancelled"
    @destroy()


