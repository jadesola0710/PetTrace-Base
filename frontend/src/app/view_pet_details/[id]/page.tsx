"use client";
import { FaHeart, FaChevronLeft, FaChevronRight } from "react-icons/fa";
import { useParams } from "next/navigation";
import { useReadContract } from "wagmi";
import PetTraceABI from "../../../../abi.json";

const CONTRACT_ADDRESS = "0xE57FdF69F2010faeD5F41209a65F1eD32Ec95E07";

interface Pet {
  id: number;
  owner: string;
  name: string;
  breed: string;
  gender: string;
  sizeCm: number;
  ageMonths: number;
  dateTimeLost: string;
  description: string;
  imageUrl: string;
  lastSeenLocation: string;
  contactName: string;
  contactPhone: string;
  contactEmail: string;
  ethBounty: number;
  usdcBounty: number;
  isFound: boolean;
  ownerConfirmed: boolean;
  finderConfirmed: boolean;
  finder: string;
}

export default function PetDetails() {
  const { id } = useParams<{ id: string }>();
  const petId = id ? BigInt(id) : BigInt(0);

  const {
    data: petData,
    isLoading,
    isError,
  } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: PetTraceABI.abi,
    functionName: "getPetDetails", // Using the public mapping getter
    args: [petId],
  });

  if (isLoading)
    return <div className="text-center py-8">Loading pet details...</div>;
  if (isError)
    return (
      <div className="text-center py-8 text-red-500">
        Error loading pet details
      </div>
    );

  // The petData will be an array of all the Pet struct fields in order
  const petArray = petData as any[];

  // Format the pet data
  const formattedPet: Pet = {
    id: Number(petId),
    owner: petArray[1], // owner is the second element in the struct
    name: petArray[2],
    breed: petArray[3],
    gender: petArray[4],
    sizeCm: Number(petArray[5]),
    ageMonths: Number(petArray[6]),
    dateTimeLost: petArray[7],
    description: petArray[8],
    imageUrl: petArray[9],
    lastSeenLocation: petArray[10],
    contactName: petArray[11],
    contactPhone: petArray[12],
    contactEmail: petArray[13],
    ethBounty: Number(petArray[14]),
    usdcBounty: Number(petArray[15]),
    isFound: petArray[16],
    ownerConfirmed: petArray[17],
    finderConfirmed: petArray[18],
    finder: petArray[19] || "",
  };

  // Create thumbnails array
  const thumbnails = [
    formattedPet.imageUrl,
    "/images/pet2.jpg",
    "/images/pet3.jpg",
    "/images/pet4.jpg",
  ];

  // Format bounty amounts
  const formatBounty = (amount: number, isUsdc: boolean = false) => {
    if (isUsdc) {
      return (amount / 1e6).toFixed(2) + " USDC";
    }
    return (amount / 1e18).toFixed(4) + " ETH";
  };

  return (
    <div className="flex flex-col md:flex-row gap-8 p-4 md:p-8 max-w-7xl mx-auto">
      {/* Left: Image + Gallery */}
      <div className="md:w-1/2 flex flex-col items-center">
        {/* MAIN IMAGE */}
        <div className="relative w-full md:h-[460px] h-[300px] overflow-hidden rounded-2xl">
          <img
            src={formattedPet.imageUrl || "/images/pet.jpg"}
            alt={formattedPet.name}
            className="object-cover w-full h-full"
          />

          {/* Desktop Nav Buttons */}
          <button className="hidden md:flex absolute top-1/2 left-2 -translate-y-1/2 bg-white p-2 rounded-full shadow">
            <FaChevronLeft />
          </button>
          <button className="hidden md:flex absolute top-1/2 right-2 -translate-y-1/2 bg-white p-2 rounded-full shadow">
            <FaChevronRight />
          </button>

          {/* Carousel dots */}
          <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1">
            {thumbnails.map((_, i) => (
              <span
                key={i}
                className="w-2 h-2 rounded-full bg-white opacity-70"
              ></span>
            ))}
          </div>
        </div>

        {/* Thumbnail strip (desktop only) */}
        <div className="hidden md:flex mt-4 gap-3">
          {thumbnails.map((src, i) => (
            <img
              key={i}
              src={src}
              alt={`thumbnail-${i}`}
              className={`w-20 h-20 rounded-xl object-cover border-2 ${
                i === 0 ? "border-indigo-500" : "border-transparent"
              }`}
            />
          ))}
        </div>

        {/* Bounty Information */}
        <div className="mt-6 w-full bg-indigo-50 p-4 rounded-xl">
          <h3 className="font-semibold text-indigo-700">Reward for Finding</h3>
          <div className="flex justify-between mt-2">
            {formattedPet.ethBounty > 0 && (
              <span className="font-medium">
                {formatBounty(formattedPet.ethBounty)}
              </span>
            )}
            {formattedPet.usdcBounty > 0 && (
              <span className="font-medium">
                {formatBounty(formattedPet.usdcBounty, true)}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Right: Pet Details */}
      <div className="md:w-1/2 space-y-4">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold">
              {formattedPet.name}
            </h1>
            <p className="text-gray-500 text-sm">
              {formattedPet.breed} • Lost on {formattedPet.dateTimeLost}
            </p>
          </div>
          <FaHeart className="text-purple-400 text-xl mt-1" />
        </div>

        {/* Gender, Size, Age */}
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-indigo-50 text-center rounded-xl py-2 text-sm font-medium text-indigo-600">
            Gender <br />
            <span className="font-semibold">{formattedPet.gender}</span>
          </div>
          <div className="bg-indigo-50 text-center rounded-xl py-2 text-sm font-medium text-indigo-600">
            Size <br />
            <span className="font-semibold">{formattedPet.sizeCm} cm</span>
          </div>
          <div className="bg-indigo-50 text-center rounded-xl py-2 text-sm font-medium text-indigo-600">
            Age <br />
            <span className="font-semibold">
              {formattedPet.ageMonths} months
            </span>
          </div>
        </div>

        {/* Description */}
        <div>
          <h3 className="font-semibold mb-1">Details:</h3>
          <p className="text-sm text-gray-700">{formattedPet.description}</p>
        </div>

        {/* Contact Info */}
        <div>
          <h3 className="font-semibold mb-1">Owner Contacts:</h3>
          <p className="text-sm leading-relaxed">
            <strong>Name:</strong> {formattedPet.contactName} <br />
            <strong>Phone:</strong> {formattedPet.contactPhone} <br />
            <strong>Email:</strong> {formattedPet.contactEmail}
          </p>
        </div>

        {/* Location + Map */}
        <div className="rounded-2xl shadow overflow-hidden">
          <iframe
            src={`https://www.google.com/maps?q=${encodeURIComponent(
              formattedPet.lastSeenLocation
            )}&output=embed`}
            className="w-full h-40 border-0"
            loading="lazy"
          ></iframe>
          <div className="p-3 text-sm">
            <p>
              <strong>Last seen at:</strong> <br />
              {formattedPet.lastSeenLocation}
            </p>
          </div>
        </div>

        {/* Buttons */}
        <div className="flex flex-col md:flex-row gap-4 mt-4">
          <button className="bg-indigo-600 text-white px-6 py-2 rounded-xl shadow hover:bg-indigo-700">
            I Found This Pet
          </button>
          <button className="border border-gray-300 px-6 py-2 rounded-xl hover:bg-gray-50">
            View All Lost Pets
          </button>
        </div>
      </div>
    </div>
  );
}
