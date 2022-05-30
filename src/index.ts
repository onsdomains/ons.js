import { ExternalProvider, JsonRpcFetchFunc, JsonRpcSigner, Web3Provider } from "@ethersproject/providers";
import axios from "axios";
import { BigNumber, Contract, ethers } from "ethers";
import AddressBook from "./contracts/AddressBook";
import NFTResolver from "./contracts/NFTResolver";
import ONSRegister from "./contracts/ONSRegsiter";
import RegisterController from "./contracts/RegisterController";
import TextResolver from "./contracts/TextResolver";
const Provider = ethers.providers.Provider


interface OnsOptionsInterface {
    provider: Web3Provider,
}
interface nameOptionsInterface {
    provider: Web3Provider,
    name: string,
    AddressBookC: Contract,
}



const errorHandling = (error: any) => {
    if (error.reason == 'ONS: NAME_EXPIRIES' || error.reason == 'ONS: THIS_ADDRESS_IS_NOT_OWNER_ANYMORE') {
        throw new Error("User does not have a primary name");
    } else if (error.reason == 'DOMAIN_IS_NOT_AVAILABLE') {
        throw new Error("Domain is not available");
    } else {
        console.log(error)
        throw new Error("Something went wrong");
    }
}
const addressIsValid = (address: string): boolean => {
    return /^0x[0-9a-fA-F]{40}$/.test(address);
}

class Name {
    private provider: Web3Provider;
    private name: string;
    private AddressBookC: Contract; // ons register
    private ONSRegisterC: Contract | undefined; // ons register
    private TextResolverC: Contract | undefined; // text resolver
    private RegisterControllerC: Contract | undefined; // register controller
    private NFTResolverC: Contract | undefined; // register controller

    constructor(options: nameOptionsInterface) {
        this.provider = options.provider;
        this.name = options.name;
        this.AddressBookC = options.AddressBookC;
    }
    private initContracts = async () => {
        if (!this.ONSRegisterC) {
            const ONSRegisterAddress = await this.AddressBookC.getContractAddress("BaseContract");
            this.ONSRegisterC = new ethers.Contract(ONSRegisterAddress, ONSRegister.abi, this.provider);
        } if (!this.NFTResolverC) {
            const ONSRegisterAddress = await this.AddressBookC.getContractAddress("NFTResolver");
            this.NFTResolverC = new ethers.Contract(ONSRegisterAddress, NFTResolver.abi, this.provider);
        }
        if (!this.TextResolverC) {
            const TextResolverAddress = await this.AddressBookC.getContractAddress("TextResolver");
            this.TextResolverC = new ethers.Contract(TextResolverAddress, TextResolver.abi, this.provider);
        }
        if (!this.RegisterControllerC) {
            const RegisterControllerAddress = await this.AddressBookC.getContractAddress("ControllerContract");
            this.RegisterControllerC = new ethers.Contract(RegisterControllerAddress, RegisterController.abi, this.provider);
        }
    }
    private getTokenId = async () => {
        await this.initContracts();
        const tokenId = this.RegisterControllerC && await this.RegisterControllerC.getDomainID(this.name);
        const isAvailable = this.ONSRegisterC && await this.ONSRegisterC.available(tokenId);
        isAvailable && errorHandling({ reason: 'DOMAIN_IS_NOT_AVAILABLE' });
        return tokenId;
    }
    getAddress = async (): Promise<string | undefined> => {
        await this.initContracts();
        try {
            const res = await this.ONSRegisterC?.getAddress(this.name)
            if (res == undefined) {
                throw new Error("This name does not exist");
            } else {
                return res
            }
        } catch (error: any) {
            throw new Error("This name does not exist");
        }
    }
    private getTextFromResolver = async (key: string) => {
        await this.initContracts();
        const tokenId = this.getTokenId();
        try {
            const res = await this.TextResolverC?.text(tokenId, key)
            if (res == undefined || res == '') {
                return undefined
            } else {
                return res
            }
        } catch (error: any) {
            throw new Error(error);
        }
    }
    getTwitter = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.twitter');
        return res
    }
    getAvatarUrl = async (): Promise<any | undefined> => {
        await this.initContracts();
        const tokenId = this.getTokenId();
        const avatar = await this.NFTResolverC?.getTokenURI(tokenId);
        try {
            const res = await axios.get(avatar)
            return res?.data?.image ? res.data.image : 'https://ons.money/img/avatar.png'
        } catch (error) {
            return 'https://ons.money/img/avatar.png';
        }
    }
    getYoutube = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.youtube');
        return res
    }
    getInstagram = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.instagram');
        return res
    }
    getEmail = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.email');
        return res
    }
    getWebsite = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.website');
        return res
    }
    getTelegram = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.telegram');
        return res
    }
    getLinkedin = async (): Promise<string | undefined> => {
        const res = await this.getTextFromResolver('com.linkedin');
        return res
    }
}

export default class ONS {
    private provider: Web3Provider;
    private AddressBookC: Contract | undefined; // address book
    private RegisterControllerC: Contract | undefined; // register controller
    private ONSRegisterC: Contract | undefined; // ons register
    constructor(options: OnsOptionsInterface) {
        const { provider } = options
        let ethersProvider
        if (Provider.isProvider(provider)) {
            //detect ethersProvider
            ethersProvider = provider
        } else {
            ethersProvider = new ethers.providers.Web3Provider(provider)
        }

        this.provider = ethersProvider
    }

    init = async () => {
        this.AddressBookC = new ethers.Contract(AddressBook.address, AddressBook.abi).connect(this.provider)
        const registerAddr = await this.AddressBookC.getContractAddress("ControllerContract")
        this.RegisterControllerC = new ethers.Contract(registerAddr, RegisterController.abi).connect(this.provider)
        const onsAddr = await this.AddressBookC.getContractAddress("BaseContract")
        this.ONSRegisterC = new ethers.Contract(onsAddr, ONSRegister.abi).connect(this.provider)
    }

    getContractAddress = async (contract: string) => {
        this.AddressBookC === undefined ? await this.init() : null;
        const address = await this.AddressBookC?.getContractAddress(contract)
        return address
    }

    name = (name: string) => {
        if (this.AddressBookC === undefined) {
            throw new Error("init() must be called first");
        }
        return new Name({ provider: this.provider, AddressBookC: this.AddressBookC, name });
    }

    getName = async (address: string): Promise<string | undefined> => {
        this.AddressBookC === undefined ? await this.init() : null;
        if (!addressIsValid(address)) {
            throw new Error("Invalid address");
        }
        try {
            const res = await this.ONSRegisterC?.getName(address)
            return res
        } catch (error: any) {
            errorHandling(error)
        }
    }



}