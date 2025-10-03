#include <iostream>
#include <sys/utsname.h>
#include <fmt/core.h>

#include <libdnf5/base/base.hpp>
#include <libdnf5/base/goal.hpp>
#include <libdnf5/rpm/package_query.hpp>
#include <libdnf5/rpm/package.hpp>
#include "cterror.h"

struct DnfConfig {
    std::string yum_repo_dir = "/etc/yum.repos.d";
};



struct RpmPackageInfo
{
    std::string name;
    std::string version;
    std::string release;
    std::string arch;
    std::string epoch;
    u_long download_size;
    u_long install_size;
    std::string summary;
    std::string description;
    std::string license;
    std::string vendor;
    std::string url;
    std::string group;
    std::vector<std::string> provides;
    std::vector<std::string> req;
    std::vector<std::string> conflicts;
};

int main()
{
    try
    {
        struct utsname uname_data;
        if (uname(&uname_data) < 0)
        {
            std::cerr << "uname failed" << std::endl;
            return 1;
        }
        auto base = std::make_unique<libdnf5::Base>();

        base->get_config().get_plugins_option().set(false);
        base->load_config();
        base->setup();
        auto repo_sack = base->get_repo_sack();
        repo_sack->create_repos_from_dir("/etc/yum.repos.d");
        //repo_sack->load_repos(libdnf5::repo::Repo::Type::SYSTEM);
        base->get_repo_sack()->load_repos(libdnf5::repo::Repo::Type::AVAILABLE);
        libdnf5::rpm::PackageQuery query(*base);
        libdnf5::Goal goal(*base);
        goal.add_install("git");
        auto tx = goal.resolve();
        auto deps = tx.get_transaction_packages();
        fmt::println("Transaction Packages: {}", deps.size());
        for (const auto &tx_pkg : deps)
        { 
            auto pkg = tx_pkg.get_package();
            fmt::println("Package: {}-{}:{}-{}.{}",
                pkg.get_name(),
                pkg.get_epoch(),
                pkg.get_version(),
                pkg.get_release(),
                pkg.get_arch());
        }
    }
    catch (const std::exception &ex)
    {
        std::cerr << "Error: " << ex.what() << std::endl;
        return 1;
    }
    return 0;
}




