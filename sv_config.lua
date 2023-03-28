svcfg = {

    locale = "pl",
    prefix = "[ZYKEM-BANSYSTEM]: ",
    logs = {
        enabled = true,
        webhook = ''
    }
    permissions = {

        ["best"] = {
            ban = true,
            kick = true,
            unban = true
        },
        ["admin"] = {
            ban = true,
            kick = true,
            unban = true
        },
        ["support"] = {
            ban = false,
            kick = false,
            unban = false
        }

    }

}