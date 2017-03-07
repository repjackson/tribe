FlowRouter.notFound =
    subscriptions: ->
    action: ->
        BlazeLayout.render 'layout',
            main: '404'



AccountsTemplates.configure
    defaultLayout: 'layout'
    # defaultLayoutRegions:
        # nav: ''
    defaultContentRegion: 'main'
    showForgotPasswordLink: true
    overrideLoginErrors: true
    enablePasswordChange: true

    sendVerificationEmail: true
    enforceEmailVerification: false
    confirmPassword: true
    continuousValidation: true
    #displayFormLabels: true
    #forbidClientAccountCreation: true
    #formValidationFeedback: true
    #homeRoutePath: '/'
    showAddRemoveServices: true
    #showPlaceholders: true

    negativeValidation: true
    positiveValidation: true
    negativeFeedback: true
    positiveFeedback: true

    # Privacy Policy and Terms of Use
    #privacyUrl: 'privacy'
    #termsUrl: 'terms-of-use'

pwd = AccountsTemplates.removeField('password')
AccountsTemplates.removeField 'email'
AccountsTemplates.addFields [
    {
        _id: 'username'
        type: 'text'
        displayName: 'username'
        required: true
        minLength: 3
    }
    {
        _id: 'email'
        type: 'email'
        required: false
        displayName: 'email'
        re: /.+@(.+){2,}\.(.+){2,}/
        errStr: 'Invalid email'
    }
    {
        _id: 'username_and_email'
        type: 'text'
        required: true
        displayName: 'Username or Email'
    }
    pwd
]


AccountsTemplates.configureRoute 'changePwd'
AccountsTemplates.configureRoute 'forgotPwd'
AccountsTemplates.configureRoute 'resetPwd'
AccountsTemplates.configureRoute 'signIn'
AccountsTemplates.configureRoute 'signUp'
AccountsTemplates.configureRoute 'verifyEmail'


