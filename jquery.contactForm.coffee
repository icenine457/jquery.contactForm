(($) ->
  settings =
    validate: true
    debug: false
    responseHeader: "Thank You!"
    responseMsg: "Your contact information and message has been sent. We will get back to you soon!"
    contactFormHeader: "Contact Us"
    contactFormMsg: "Please use this form to contact us at your convenience."
    preferredContactMethods: [ "Choose a contact method", "Phone", "E-mail" ]
    postUrl: "/Home/PostContactUs"
    maxNameLength: 100
    dontSend: false

  createInput = (parent, labelText, namePrefix, inputType = "text") ->
    labelDiv = $("<div />",
      class: "label"
    )
    label = $("<label />",
      text: labelText
    ).appendTo labelDiv

    parent.append labelDiv

    inputDiv = $("<div />",
      class: "input"
    )

    input = ""

    switch inputType
      when "select"
        input = $("<select />",
          type: inputType
          val: ""
          name: namePrefix + "Input"
        )
        populateOptions($(input), settings.preferredContactMethods)
      when "textarea"
        input = $("<textarea />",
          type: inputType
          rows: 10
          val: ""
          name: namePrefix + "Input"
          'data-val-text': labelText + " is not valid"
        )
      when "button"
        input = $("<input />",
          type: "button"
          val: "Submit"
          name: namePrefix + "Input"
        )
      else
        input = $("<input />",
          type: inputType
          val: ""
          class: 'required'
          'data-val-text': labelText + " is not valid"
          name: namePrefix + "Input"
        )


    input.appendTo inputDiv
    parent.append inputDiv
    return input


  populateOptions = (parent, options) ->
    parent.append $("<option>" + option + "</option>", value: option) for option in options

  createHeading = (parent, headerText, message) ->
    responseDiv = $("<div class='message-body-response-header' />")

    header = $("<h1>" + headerText + "</h1>")
    responseText = $("<p>" + message + "</p>")

    header.appendTo responseDiv
    responseText.appendTo responseDiv

    responseDiv.appendTo parent

    return responseDiv

  methods =
    init: (options) ->
      console?.log "Preparing contactForm"
      @each ->
        thisRef = $(@)

        form = $("<form>",
          class: "contactForm"
          method: "get"
          action: ""
        )
        settings = $.extend settings, options

        contactFormHead = createHeading(thisRef, settings.contactFormHeader, settings.contactFormMsg)
        responseHead = createHeading(thisRef, settings.responseHeader, settings.responseMsg)
        responseHead.hide()
        nameInput  = createInput(form, "Name", "name")
        emailInput = createInput(form, "Email", "email")
        phoneInput = createInput(form, "Phone", "phone")
        preferredContactMethodInput = createInput(form, "Contact me via", "preferredContact", "select")
        subjectInput = createInput(form, "Subject", "subject")
        messageInput = createInput(form, "Message", "message", "textarea")
        submitInput = createInput(form, "", "submit", "button")
        form.appendTo $(@)
		
        submitInput.click ->
          # Validation method would go here
          return unless settings.validate and formIsValid form
          postData =
            ContactName: nameInput.val()
            ContactEmail: emailInput.val()
            ContactPhone: phoneInput.val()
            ContactVia: preferredContactMethodInput.val()
            ContactSubject: subjectInput.val()
            ContactMessage: messageInput.val()

          console?.log JSON.stringify(postData) if options.debug
          form.hide()
          contactFormHead.hide()
          responseHead.show()

          if !settings.dontSend
            $.ajax settings.postUrl,
              type: 'POST'
              dataType: 'json'
              data: postData
          
    destroy: () ->
      console?.log "Removing"
      @find('a').each (index, element) =>
        $(element).tipsy "hide"
      @empty()

  formIsValid = (form) ->
    invalid = 0
    form.find('input, textarea').each (index, element) =>

      thisInput = $(element)
      thisInputInvalid = false

      if $.fn.tipsy
        tipsyDiv = $('body').find('div.tipsy-inner:contains("' + thisInput.attr('data-val-text') + '")')
        if tipsyDiv
          tipsyDiv.parent().remove()

      switch thisInput.attr('name')
        when "nameInput", "subjectInput", "messageInput"
          if thisInput.val().length < 2 or !/[A-Za-z0-9'].*/.test(thisInput.val())
            invalid++
            thisInputInvalid = true
        when "phoneInput"
          phoneVal = thisInput.val().replace(/[\+\(\)\-x\s]/g, '')
          if phoneVal and isNaN phoneVal
            invalid++
            thisInputInvalid = true
        when "emailInput"
          emailRe = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
          if thisInput.val().length < 6 or !emailRe.test(thisInput.val())
            invalid++
            thisInputInvalid = true

      if thisInputInvalid
        valElem = $("<a />",
          title: thisInput.attr('data-val-text')
          href: "#"
        )
        thisInput.after(valElem)
        if $.fn.tipsy
          valElem.tipsy
            trigger: 'manual'
            gravity: 'w'
            fade: true
          valElem.tipsy "show"



    if invalid > 0 then return false else return true

  $.fn.contactForm = (method) ->
    if methods[method]
      methods[method].apply this, Array.prototype.slice.call arguments, 1
    else if typeof method is 'object' or !method
      methods.init.apply this, arguments
    else
      $.error "jQuery.pluginName: Method #{ method } does not exist on jQuery.pluginName"
  return
)(jQuery)

